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

	/* Mote-Steuerung per Konsole */
	command void NodeTools.serialInit() {
		call SerialAMCtrl.start();
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

	/* Antwort senden */
	command void NodeTools.sendResponse(node_msg_t* response) {
		error_t result;
		node_msg_t *pmsg;

		if (!sAvailable) {
			return;
		}

		/* Parameter kopieren (in eine eigene message_t-Instanz) */
		pmsg = (node_msg_t*) call SerialPacket.getPayload(&sPacket, sizeof(node_msg_t));
		memcpy(pmsg, response, sizeof(node_msg_t));

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
			call NodeTools.setLed(LED_RED, TRUE);
		}
	}

	/* Paket über die Konsole erhalten */
	event message_t* SerialReceive.receive(message_t* bufPtr, void* payload, uint8_t len) {
		node_msg_t *pmsg = (node_msg_t*) payload;
		uint8_t led;
		am_addr_t myAddr;

		if (len != sizeof(node_msg_t)) {
			return bufPtr;
		}

		myAddr = call AMPacket.address();

		/* "native" Kommandos implementieren, benutzerdefinierte weiterreichen */
		switch (pmsg->cmd) {
			case CMD_LEDON:
				if (pmsg->data[0] == myAddr) {
					led = pmsg->data[1];
					call NodeTools.setLed(led, TRUE);
				}
				break;

			case CMD_LEDOFF:
				if (pmsg->data[0] == myAddr) {
					led = pmsg->data[1];
					call NodeTools.setLed(led, FALSE);
				}
				break;

			case CMD_LEDTOGGLE:
				if (pmsg->data[0] == myAddr) {
					led = pmsg->data[1];
					if (call Leds.get() && led) {
						call NodeTools.setLed(led, FALSE);
					} else {
						call NodeTools.setLed(led, TRUE);
					}
				}
				break;

			case CMD_LEDBLINK:
				if (pmsg->data[0] == myAddr) {
					led = pmsg->data[1];
					call NodeTools.flashLed(led, pmsg->data[2]);
				}
				break;

			case CMD_USERCMD:
				signal NodeTools.onCommand(pmsg);

		}

		return bufPtr;
	}
}

