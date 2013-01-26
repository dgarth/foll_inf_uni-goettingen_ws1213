// vim: filetype=nc:tabstop=4:expandtab:shiftwidth=0:softtabstop=-1

// NodeToolsP.nc - Implementierung des Interfaces NodeTools.

/**
**/

#include "../allnodes.h"
#define QUEUE_LEN 10

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
	bool locked = FALSE; // Lock, damit keine Daten verloren gehen.
	bool sAvailable = FALSE; // Angabe, ob init() aufgerufen wurde.
	uint8_t myID; // Eigene Radio-Adresse

	// Message queue
	node_msg_t msgQueue[QUEUE_LEN];
	uint8_t qpRead = 0;
	uint8_t qpWrite = 0;

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


	/* Mote-Steuerung per Konsole - Initialisierung */
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


	/* Kommunikation über den SerialPort */
	command void NodeTools.serialSendOK() {
		node_msg_t msg;
		msg.cmd = S_OK;
		msg.length = 0;
		msg.moreData = 0;
		call NodeTools.enqueueMsg(&msg);
	}

	command void NodeTools.debugPrint(const char* str) {
		size_t len;
		node_msg_t msg;
		uint8_t msgCount = 0;

		msg.cmd = DEBUG_OUTPUT;
		len = strlen(str);

		// Nachrichten mit je MAX_DATA Zeichen produzieren
		while (len > 0) {
			size_t chunk = (len <= MAX_DATA) ? len : MAX_DATA;
			memcpy(msg.data, &str[MAX_DATA * msgCount], chunk);
			msg.length = chunk;

			if (len > MAX_DATA) {
				msg.moreData = 1;
			} else {
				msg.moreData = 0;
			}

			len -= chunk;
			msgCount++;

			call NodeTools.enqueueMsg(&msg);
		}

	}

	task void serialSendMsg() {
		error_t result;
		node_msg_t *pmsg;

		if (call NodeTools.queueEmpty() || !sAvailable) {
			return;
		}
		
		/* Parameter kopieren (in eine eigene message_t-Instanz) */
		pmsg = (node_msg_t*) call SerialPacket.getPayload(&sPacket, sizeof(node_msg_t));
		memcpy(pmsg, call NodeTools.dequeueMsg(), sizeof(node_msg_t));

      	result = call SerialAMSend.send(AM_BROADCAST_ADDR, &sPacket, sizeof(node_msg_t));
		if (result == SUCCESS) {
			locked = TRUE;
		}
		
	}

	event void SerialAMSend.sendDone(message_t* bufPtr, error_t error) {

		if (&sPacket == bufPtr) {
			locked = FALSE;
		}
		if (error != SUCCESS) {
			sAvailable = FALSE;
			call NodeTools.setLed(LED_RED, TRUE);
		}

		/* Ggf. weitere Nachricht versenden */
		if (! call NodeTools.queueEmpty()) {
			post serialSendMsg();
		}

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
						call NodeTools.enqueueMsg(&rmsg);
						break;
					}
				}

				// Sollen noch weitere Nodes gepingt werden?
				if (pmsg->length > 1) {
					sigDis = TRUE;
				}

				call NodeTools.serialSendOK();
				break;

			case CMD_LEDON:
				if (myID == pmsg->data[0]) {
					led = pmsg->data[1];
					call NodeTools.setLed(led, TRUE);
				} else { sigDis = TRUE; }

				call NodeTools.serialSendOK();
				break;

			case CMD_LEDOFF:
				if (myID == pmsg->data[0]) {
					led = pmsg->data[1];
					call NodeTools.setLed(led, FALSE);
				} else { sigDis = TRUE; }

				call NodeTools.serialSendOK();
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

				call NodeTools.serialSendOK();
				break;

			case CMD_LEDBLINK:
				if (myID == pmsg->data[0]) {
					led = pmsg->data[1];
					call NodeTools.flashLed(led, pmsg->data[2]);
				} else { sigDis = TRUE; }

				call NodeTools.serialSendOK();
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

	/* Verwaltung der Message queue */
	command bool NodeTools.queueEmpty() {
		return qpRead == qpWrite;
	}

	command void NodeTools.enqueueMsg(node_msg_t *pmsg) {
		memcpy(msgQueue+qpWrite, pmsg, sizeof(node_msg_t));
		qpWrite++;
		qpWrite %= QUEUE_LEN;

		/* Nachricht direkt absenden, falls nicht gerade gesendet wird */
		if (!locked) {
			post serialSendMsg();
		}
	}

	command node_msg_t* NodeTools.dequeueMsg() {
		node_msg_t *pmsg = NULL;

		if (!call NodeTools.queueEmpty()) {
			pmsg = msgQueue + qpRead;
		}

		qpRead++;
		qpRead %= QUEUE_LEN;
		return pmsg;
	}
}

