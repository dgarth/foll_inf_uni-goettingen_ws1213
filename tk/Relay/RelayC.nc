/* RelayC: Implementiert die Logik der Relay-Mote. */

#include <printf.h>
#include "allnodes.h"

module RelayC {
	/** allgemein **/
	uses interface Boot;
	uses interface NodeTools as Tools;

	/* Timer für ACK-Request vom Sink;
	 * erfordert fired() */
	uses interface Timer<TMilli> as TAckRequest;

	/** RF **/
	/* erfordert sendDone() */
	uses interface AMSend;
	/* erfordert receive() */
	uses interface Receive;
	uses interface Packet; /* Paket-Payload */
	uses interface AMPacket; /* Paketmetadaten (isForMe, ...) */
	uses interface PacketAcknowledgements as PackAcks;

	/* erfordert startDone(), stopDone() */
	uses interface SplitControl as AMControl;
}

implementation {
	/* Deklarationen */
	message_t pingPacket;
	message_t dataPacket;
	error_t lastErr;
	am_addr_t relayTarget;

	task void relayData();

	/* Boot-Handler */
	event void Boot.booted() {
		flushMsg("Hello World from RELAY.\n");

		/* RF-Chip initialisieren */
		call AMControl.start();

		if (call AMPacket.address() != RELAY_ID) {
			flushMsg("WARN: RELAY_ID and current address do not match!\n");
		}
	}

	/* SplitControl-Handler */
	event void AMControl.startDone(error_t error) {
		call Tools.perror(error, "AMControl.startDone", "RF chip initialized.\n");

		/* RF-Chip ist verfügbar, wenn error == SUCCESS */
		if (error == SUCCESS) {
			/* Erfolg signalisieren */
			call Tools.flashLed(LED_BLUE, 2);
			/* Timer für ACK-Request starten.
			 * Alle 5 Sekunden testen, ob die Sink noch da ist. */
			call TAckRequest.startPeriodic(5000);
		}
	}

	event void AMControl.stopDone(error_t error) {
		call Tools.perror(error, "AMControl.stopDone", "RF chip power down succeeded.\n");
	}

	/* TAckRequest-Handler */
	event void TAckRequest.fired() {
		RFMessage *pmsg;
		error_t result;

		pmsg = (RFMessage*) (call Packet.getPayload(&pingPacket, sizeof(RFMessage)));
		pmsg->sender = call AMPacket.address();
		pmsg->control = CTRL_PING;

		call Tools.flashLed(LED_RED, 1);
		call PackAcks.requestAck(&pingPacket);
		result = call AMSend.send(SINK_ID, &pingPacket, sizeof(RFMessage));
		call Tools.perror(result, "TAckRequest.fired", "Relay: ACK requested\n");
	}

	/* AMSend-Handler */
	event void AMSend.sendDone(message_t *msg, error_t error) {
		RFMessage *pmsg;

		call Tools.perror(error, "AMSend.sendDone", "");
		pmsg = (RFMessage*) (call Packet.getPayload(msg, sizeof(RFMessage)));

		if (!pmsg) {
			flushMsg("Error: sendDone: Could not retrieve payload.\n");
			return;
		}

		switch (pmsg->control) {
			case CTRL_PING:
				if (call PackAcks.wasAcked(msg)) {
					call Tools.setLed(LED_BLUE, TRUE);
				} else {
					call Tools.setLed(LED_BLUE, FALSE);
				}
				break;
		}

	}

	/* Receive-Handler */
	event message_t* Receive.receive(message_t *msg, void *payload, uint8_t len) {
		RFMessage *pmsg, *prelay;

		/* Paket empfangen - grüne LED einmal blinken lassen */
		call Tools.flashLed(LED_GREEN, 1);
		pmsg = (RFMessage*) payload;
		prelay = (RFMessage*) (call Packet.getPayload(&dataPacket, sizeof(RFMessage)));

		/* nur Nachrichten akzeptieren, die für RELAY_ID bestimmt sind. */
		if (!(call AMPacket.isForMe(msg))) {
			flushMsg("Relay: Packet not for me\n");
			return msg;
		}

		/* Bestimmte Nachrichten an die Sink weiterleiten */
		switch (pmsg->control) {
			case CTRL_PING: /* Relay <- Sink */
				flushMsg("Relay: Echo request from node %d.\n", pmsg->sender);
				break;
			case CTRL_NEWMEASURE: /* Feld -> Relay -> Sink */
				prelay->control = CTRL_NEWMEASURE;
				relayTarget = SINK_ID;
				post relayData();
				break;
			case CTRL_RSSIDATA: /* Feld -> Relay -> Sink */
				prelay->control = CTRL_RSSIDATA;
				relayTarget = SINK_ID;
				post relayData();
				flushMsg("Relaying data: Node %d --> %d, RSSI = %d.\n", pmsg->data1, pmsg->data2, pmsg->data3);
				break;
			case CTRL_REPLY: /* Relay <- Sink */
				
				//if (pmsg->data2 == REPLY_PING) {
				//	printf("Echo reply from %d.\n", pmsg->sender);
				//} else {
					flushMsg("Reply from %d, errno = %d.\n", pmsg->sender, pmsg->data1);
				//}
		}

		return msg;
	}

	task void relayData() {
		RFMessage *pmsg;
		error_t result;

		pmsg = (RFMessage*) (call Packet.getPayload(&dataPacket, sizeof(RFMessage)));
		pmsg->sender = RELAY_ID;
		result = call AMSend.send(relayTarget, &dataPacket, sizeof(RFMessage));

		if (result != SUCCESS) {
			call Tools.perror(result, "task relayData", "Packet relayed.");
		}
	}

}
