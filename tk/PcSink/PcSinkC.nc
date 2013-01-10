// PcSinkC: Implementiert die Logik der PcSink-Mote.

/**
**/

#include <printf.h>
#include "allnodes.h"

module PcSinkC {
	/** allgemein **/
	uses interface Boot;
	uses interface NodeTools as Tools;

	/* Timer für ACK-Request vom Relay;
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

	task void sendReply();

	/* Boot-Handler */
	event void Boot.booted() {
		flushMsg("Hello World from SINK.\n");

		/* RF-Chip initialisieren */
		call AMControl.start();

		if (call AMPacket.address() != SINK_ID) {
			flushMsg("WARN: SINK_ID and current address do not match!\n");
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
			 * Alle 5 Sekunden testen, ob das Relay noch da ist. */
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
		result = call AMSend.send(RELAY_ID, &pingPacket, sizeof(RFMessage));
		call Tools.perror(result, "TAckRequest.fired", "Sink: ACK requested\n");
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
		RFMessage *pmsg;

		/* Paket empfangen - grüne LED einmal blinken lassen */
		call Tools.flashLed(LED_GREEN, 1);
		pmsg = (RFMessage*) payload;

		/* nur Nachrichten akzeptieren, die für SINK_ID bestimmt sind
		 * und vom Relay kommen. */
		if (!(call AMPacket.isForMe(msg))) {
			flushMsg("Sink: Packet not for me\n");
			return msg;
		} else if (pmsg->sender != RELAY_ID) {
			flushMsg("Sink: Packet not from relay\n");
			return msg;
		}

		/* alle Nachrichten kommen vom Relay. */
		switch (pmsg->control) {
			case CTRL_PING:
				flushMsg("Sink: Echo request from node %d.\n", pmsg->sender);
				break;
			case CTRL_NEWMEASURE:
				flushMsg("--new Measure--\n");
				lastErr = SUCCESS;
				post sendReply();
				break;
			case CTRL_RSSIDATA:
				flushMsg("Node %d --> %d, RSSI = %d.\n", pmsg->data1, pmsg->data2, pmsg->data3);
				break;
			case CTRL_REPLY:
				//if (pmsg->data2 == REPLY_PING) {
				//	printf("Echo reply from %d.\n", pmsg->sender);
				//} else {
					flushMsg("Reply from %d, errno = %d.\n", pmsg->sender, pmsg->data1);
				//}
		}

		return msg;
	}

	task void sendReply() {
		RFMessage *pmsg;
		error_t result;

		pmsg = (RFMessage*) (call Packet.getPayload(&dataPacket, sizeof(RFMessage)));
		pmsg->sender = SINK_ID;
		pmsg->control = CTRL_REPLY;
		pmsg->data1 = lastErr;
		result = call AMSend.send(RELAY_ID, &dataPacket, sizeof(RFMessage));

		if (result != SUCCESS) {
			call Tools.perror(result, "task sendReply", "Reply sent");
		}
	}

}
