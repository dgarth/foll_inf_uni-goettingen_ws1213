//

/**
**/

/* NodeToolsP.nc - Implementierung des Interfaces NodeTools. */

#include <printf.h>
#include "allnodes.h"

module NodeToolsP {
	provides interface NodeTools;
	uses {
		interface Leds;
		interface Timer<TMilli> as TBlinkLed0;
		interface Timer<TMilli> as TBlinkLed1;
		interface Timer<TMilli> as TBlinkLed2;
    	/* Konsolensteuerung */
    	interface SplitControl as SerialAMCtrl;
		interface Receive as SerialReceive;
    	interface AMSend as SerialAMSend;
    	interface Packet as SerialPacket;
		interface AMPacket;
	}
}

implementation {
	uint16_t blinkCount[3];
	uint8_t blinkLed;
	message_t sPacket; // Paket über den SerialPort
	bool locked = FALSE; // Lock, um den SerialPort nicht zu überfordern
	bool sAvailable = FALSE; // Angabe, ob init() aufgerufen wurde.
	uint8_t myID; // Eigene Radio-Adresse

	/* Variablen für debugPrint */
	bool moreData = FALSE;
	size_t dmLen; // Länge der gesamten Nachricht
	uint8_t dpCount; // Anzahl bereits versendeter Pakete

	/* Schaltet LEDs an oder aus. */
	command void NodeTools.setLed(uint8_t led, bool on) {
		uint8_t state = call Leds.get();

		if (on) {
			call Leds.set(state | led);
		} else {
			call Leds.set(state & ~led);
		}

	}

	/* Lässt die angegebene LED times mal blinken. */
	command void NodeTools.flashLed(uint8_t led, uint8_t times) {

		switch (led) {
			case LED_RED:
				blinkCount[0] = 2 * times;
				call TBlinkLed0.startPeriodic(100);
				break;
			case LED_GREEN:
				blinkCount[1] = 2 * times;
				call TBlinkLed1.startPeriodic(100);
				break;
			case LED_BLUE:
				blinkCount[2] = 2 * times;
				call TBlinkLed2.startPeriodic(100);
				break;
		}
	}

	/* TBlink-Handler */
	event void TBlinkLed0.fired() {
		call NodeTools.setLed(LED_RED, blinkCount[0] % 2 == 0);
		blinkCount[0] -= 1;
		if (blinkCount[0] == 0) {
			call TBlinkLed0.stop();
		}
	}

	event void TBlinkLed1.fired() {
		call NodeTools.setLed(LED_GREEN, blinkCount[1] % 2 == 0);
		blinkCount[1] -= 1;
		if (blinkCount[1] == 0) {
			call TBlinkLed1.stop();
		}
	}

	event void TBlinkLed2.fired() {
		call NodeTools.setLed(LED_BLUE, blinkCount[2] % 2 == 0);
		blinkCount[2] -= 1;
		if (blinkCount[2] == 0) {
			call TBlinkLed2.stop();
		}
	}


	/* Gibt die String-Darstellung des übergebenen Fehlers mit printf() aus.
	 * Wenn err == SUCCESS, wird nur msg ausgegeben, sonst wird failmsg an den
	 * ausgegebenen Fehler angehängt. */
	command void NodeTools.perror(error_t err, const char* failmsg, const char* msg) {
		/* TODO Gibt es sowas wie strerror? */
		char buffer[50];

		switch (err) {
			case EBUSY:
				strcpy(buffer, "EBUSY");
				break;
			case FAIL:
				strcpy(buffer, "FAIL");
				break;
		}
		if (err == SUCCESS) {
			printf("%s", msg);
		} else {
			printf("Error %s in %s.\n", buffer, failmsg);
		}
		printfflush();
	}

	//TODO das sollte in den Flash-Speicher, weil der Puffer zu viel RAM verbraucht.
	char dBuffer[256];

	command void NodeTools.debugPrint(const char* str) {
		size_t len;
		uint8_t i;
		node_msg_t msg;

		// String sichern
		strncpy(dBuffer, str, 255);

		len = strlen(str);
		msg.cmd = DEBUG_OUTPUT;

		// immer 25 Zeichen in eine Nachricht packen
		for (i = 0; i < (len <= 25 ? len : 25); i++) {
			msg.data[i] = str[i];
		}

		msg.length = i;
		if (len > 25) {
			msg.moreData = 1;
			moreData = TRUE;
		} else {
			msg.moreData = 0;
		}

		dpCount = 1;

		// erste (Teil-)Nachricht absenden
		call NodeTools.serialSendMsg(&msg);
	}

	/* Mote-Steuerung per Konsole */
	command void NodeTools.serialInit() {
		call SerialAMCtrl.start();
		myID = call AMPacket.address();
	}

	event void SerialAMCtrl.startDone(error_t err) {
		if (err == SUCCESS) {
			sAvailable = TRUE;
		}
	}

	command void NodeTools.serialShutdown() {
		call SerialAMCtrl.stop();
	}

	event void SerialAMCtrl.stopDone(error_t err) {
		if (err == SUCCESS) {
			sAvailable = FALSE;
		}
	}

	command uint8_t NodeTools.myAddress() {
		return myID;
	}

	command void NodeTools.serialSendMsg(node_msg_t* msg) {
		error_t result;
		node_msg_t *pmsg;

		if (!sAvailable) {
			return;
		}

		/* Parameter kopieren (in eine eigene message_t-Instanz) */
		pmsg = (node_msg_t*) call SerialPacket.getPayload(&sPacket, sizeof(node_msg_t));
		memcpy(pmsg, msg, sizeof(node_msg_t));

      	result = call SerialAMSend.send(AM_BROADCAST_ADDR, &sPacket, sizeof(node_msg_t));
		if (result == SUCCESS) {
			locked = TRUE;
		}
	}

	event void SerialAMSend.sendDone(message_t* bufPtr, error_t error) {
		size_t len;
		uint8_t i;
		node_msg_t msg;

		if (&sPacket == bufPtr) {
			locked = FALSE;
		}
		if (error != SUCCESS) {
			sAvailable = FALSE;
			call NodeTools.setLed(LED_RED, TRUE);
		}

		/* Nachricht ggf. vervollständigen */
		if (moreData) {
			len = strlen(dBuffer) - (25 * dpCount);
			msg.cmd = DEBUG_OUTPUT;

			// immer 25 Zeichen in eine Nachricht packen
			for (i = 0; i < (len <= 25 ? len : 25); i++) {
				msg.data[i] = dBuffer[25*dpCount+i];
			}

			msg.length = i;
			if (len > 25 && i == 25) {
				msg.moreData = 1;
				moreData = TRUE;
			} else {
				msg.moreData = 0;
				moreData = FALSE;
			}

			call NodeTools.serialSendMsg(&msg);
			dpCount++;
		} // if moreData

	}

	/* Paket über die Konsole erhalten */
	event message_t* SerialReceive.receive(message_t* bufPtr, void* payload, uint8_t len) {
		node_msg_t *pmsg = (node_msg_t*) payload;
		node_msg_t rmsg; // Antwortnachricht für CMD_ECHO
		uint8_t led;
		uint8_t i;
		/* Event signalisieren, falls das empfangene Paket weiterverteilt
		 * werden muss ("signal dissemination") */
		bool sigDis = FALSE;

		if (len != sizeof(node_msg_t)) {
			return bufPtr;
		}

		// Speicher der Antwortnachricht auf 0 setzen	
		memset(&rmsg, 0, sizeof(node_msg_t));

		/* "native" Kommandos implementieren, benutzerdefinierte weiterreichen */
		switch (pmsg->cmd) {
			case CMD_ECHO:
				// Testen, ob unsere ID im Paket enthalten ist
				for (i = 0; i < pmsg->length; i++) {
					if (myID == pmsg->data[i]) {
						rmsg.cmd = CMD_ECHO;
						rmsg.data[0] = (uint8_t) myID;
						rmsg.length = 1;
						call NodeTools.serialSendMsg(&rmsg);
						break;
					}
				}

				// Sollen noch weitere Nodes gepingt werden?
				if (pmsg->length > 1) {
					sigDis = TRUE;
				}
				break;

			case CMD_LEDON:
				call NodeTools.debugPrint("012345678901234567895(25)12345");
				if (myID == pmsg->data[0]) {
					led = pmsg->data[1];
					call NodeTools.setLed(led, TRUE);
				} else { sigDis = TRUE; }
				break;

			case CMD_LEDOFF:
				if (myID == pmsg->data[0]) {
					led = pmsg->data[1];
					call NodeTools.setLed(led, FALSE);
				} else { sigDis = TRUE; }
				break;

			case CMD_LEDTOGGLE:
				if (myID == pmsg->data[0]) {
					led = pmsg->data[1];
					if (call Leds.get() && led) {
						call NodeTools.setLed(led, FALSE);
					} else {
						call NodeTools.setLed(led, TRUE);
					}
				} else { sigDis = TRUE; }
				break;

			case CMD_LEDBLINK:
				if (myID == pmsg->data[0]) {
					led = pmsg->data[1];
					call NodeTools.flashLed(led, pmsg->data[2]);
				} else { sigDis = TRUE; }
				break;

			default:
				signal NodeTools.onSerialCommand(pmsg);
				break;

		}

		/* Event zum Verteilen feuern, falls die Nachricht nicht
		 * für mich selbst ist. */
		if (sigDis) {
			signal NodeTools.onSerialCommand(pmsg);
		}

		return bufPtr;
	}
}

