// vim: filetype=nc:tabstop=4:expandtab:shiftwidth=0:softtabstop=-1

// NodeCommP.nc - Implementierung des Interfaces NodeComm.

/**
**/

#include "../allnodes.h"

module NodeCommP {
	provides interface NodeComm;
	uses {
		interface NodeTools;
		interface Leds;
		// Radio
		interface SplitControl as AMControl;
		// Dissemination
		interface StdControl as DisControl;
		interface DisseminationUpdate<node_msg_t> as DisUpdate;
		interface DisseminationValue<node_msg_t> as DisMsg;
		// Collection
		interface StdControl as RoutingControl;
		interface Send as ColSend;
		interface Receive as ColReceive;
		interface RootControl;
	}
}

implementation {
	bool available = FALSE;
	bool collBusy = FALSE;
	message_t collPacket;
	node_msg_t *collMsg;

	command void NodeComm.init() {
		call AMControl.start();
	}

	/*** AMControl ***/

	event void AMControl.startDone(error_t err) {
		error_t result;

		if (err == SUCCESS) {
			// Dissemination initialisieren
			result = call DisControl.start();
			if (result != SUCCESS) { return; }

			// Collection initialisieren
			result = call RoutingControl.start();
			if (result != SUCCESS) { return; }

			if (TOS_NODE_ID == SINK_ID) {
				result = call RootControl.setRoot();
				if (result != SUCCESS) { return; }
			}

			available = TRUE;
		}
	}

	event void AMControl.stopDone(error_t err) {
		available = FALSE;
	}

	/*** NodeComm-Commands ***/

	command void NodeComm.dissSend(node_msg_t* cmd) {
		if (!available) { return; }
		// Kommando im Netzwerk verteilen
		call DisUpdate.change(cmd);
	}

	command void NodeComm.collSend(node_msg_t* msg) {
		error_t result;

		if (!available) { return; }

		// Report an die Basisstation routen
		if (!collBusy) {
			collMsg = call ColSend.getPayload(&collPacket, sizeof(node_msg_t));
			// Nachricht in den lokalen Speicher kopieren und absenden.
			memcpy(collMsg, msg, sizeof(node_msg_t));
			result = call ColSend.send(&collPacket, sizeof(node_msg_t));

			if (result == SUCCESS) {
				collBusy = TRUE;
			}
		}
	}

	/*** Events ***/

	event void ColSend.sendDone(message_t *msg, error_t error) {
		if (&collPacket == msg) {
			collBusy = FALSE;
		}
	}

	// Kommando empfangen (Dissemination receive signalisieren)
	event void DisMsg.changed() {
		const node_msg_t* pmsg = call DisMsg.get();
		node_msg_t rmsg; // Antwortnachricht für CMD_ECHO
		uint8_t led;
		uint8_t i;

		/* "native" Kommandos implementieren, Rest weiterreichen.
		 * Kommandos, die nicht für die eigene ID bestimmt sind, ignorieren. */
		switch (pmsg->cmd) {
			case CMD_ECHO:
				// Testen, ob unsere ID im Paket enthalten ist
				for (i = 0; i < pmsg->length; i++) {
					if (TOS_NODE_ID == pmsg->data[i]) {
						// Speicher der Antwortnachricht auf 0 setzen	
						memset(&rmsg, 0, sizeof(node_msg_t));
						rmsg.cmd = CMD_ECHO;
						rmsg.data[0] = TOS_NODE_ID;
						rmsg.length = 1;
						call NodeComm.collSend(&rmsg);
						break;
					}
				}
				break;

			case CMD_LEDON:
				if (TOS_NODE_ID == pmsg->data[0]) {
					led = pmsg->data[1];
					call NodeTools.setLed(led, TRUE);
				}
				break;

			case CMD_LEDOFF:
				if (TOS_NODE_ID == pmsg->data[0]) {
					led = pmsg->data[1];
					call NodeTools.setLed(led, FALSE);
				}
				break;

			case CMD_LEDTOGGLE:
				if (TOS_NODE_ID == pmsg->data[0]) {
					led = pmsg->data[1];
					if (call Leds.get() && led) {
						call NodeTools.setLed(led, FALSE);
					} else {
						call NodeTools.setLed(led, TRUE);
					}
				}
				break;

			case CMD_LEDBLINK:
				if (TOS_NODE_ID == pmsg->data[0]) {
					led = pmsg->data[1];
					call NodeTools.flashLed(led, pmsg->data[2]);
				}
				break;

			default:
				signal NodeComm.dissReceive(pmsg);
				break;

		}
    }

	// Report empfangen (Collection receive signalisieren)
	event message_t* ColReceive.receive(message_t *msg, void *payload, uint8_t len) {
		node_msg_t *pmsg;

		if (len != sizeof(node_msg_t)) {
			return msg;
		}

        pmsg = call ColSend.getPayload(msg, sizeof(node_msg_t));
		signal NodeComm.collReceive(pmsg);

		return msg;
	}

	event void NodeTools.onSerialCommand(node_msg_t* cmd) {
	}

}

