// Das vi-Syntaxhighlighting funktioniert (bei mir) nur mit diesem seltsamen Kommentar-Konstrukt am Anfang.

/**
**/

#include "../allnodes.h"

module MeasureTestC {
    uses {
        interface NodeTools;
        interface Boot;
        /*interface Timer<TMilli> as Timer;*/
        interface Measure;
    }
}

implementation {
	uint8_t myID; // eigene ID, festgelegt in booted()
	uint8_t partnerID; // Messpartner, festgelegt bei CMD_NEWMEASURE
	uint16_t measureSet; // Messreihe, dito
	uint32_t startTime;

    event void Boot.booted(void) {
        call NodeTools.serialInit();
		myID = call NodeTools.myAddress();
		// Andis LCD ansprechen
    }
    
	// Command event von Andis LCD (commt noch)

    event void Measure.setupDone(error_t error) {
		call NodeTools.debugPrint("setup done");
        call Measure.start();
    }

	/* Empfängt alle Kommandos, die NodeToolsP 
	 * nicht selbst behandeln kann. */
    event void NodeTools.onSerialCommand(node_msg_t* cmd) {
		struct measure_options opts;
        
		switch (cmd->cmd) {
			case CMD_NEWMEASURE:
				if (myID == cmd->data[0]) {
					partnerID = cmd->data[1];
					//measureSet = makeWORD(data, 2);
					//startTime = makeDWORD(data, 4);
					opts.partner = partnerID;
					opts.interval = 500;
					opts.count = 0;
					call Measure.setup(opts);
				} else {
					call NodeTools.debugPrint("newmeasure dissemination");
					// Nachricht ist nicht für mich selbst - per dissemination weiterleiten
				}

				call NodeTools.serialSendOK();
				break;

			case CMD_STARTMS:
				if (myID == cmd->data[0] && partnerID == cmd->data[1]) {
					// start measure
				} else {
					call NodeTools.debugPrint("startms dissemination");
				}

				call NodeTools.serialSendOK();
				break;

			case CMD_STOPMS:
				if (myID == cmd->data[0] && partnerID == cmd->data[1]) {
					// stop measure
				} else {
					call NodeTools.debugPrint("stopms dissemination");
				}

				call NodeTools.serialSendOK();
				break;

			case CMD_CLEARMS:
				if (myID == cmd->data[0] && partnerID == cmd->data[1]) {
					// clear measure
				} else {
					call NodeTools.debugPrint("clearms dissemination");
				}

				call NodeTools.serialSendOK();
				break;

			default:
				call NodeTools.debugPrint("WARN: Undefined command.");
				call NodeTools.serialSendOK();
				break;
		}
    }

	/* Neue Messung empfangen - Report senden */
    event void Measure.received(uint8_t rssi, uint32_t time) {
		node_msg_t m;
		uint8_t i;

		m.cmd = CMD_REPORT;
		m.data[0] = myID;

		// Messreihe: data[1...2]
		m.data[1] = measureSet >> 8;
		m.data[2] = measureSet;

		// Timestamp: data[3...6]
		time += startTime;
		for (i = 0; i < 4; i++) {
			m.data[6-i] = time >> (i * 8);
		}

		m.data[7] = rssi;
		m.data[8] = partnerID;
		m.length = 9;
		m.moreData = 0;
        
		call NodeTools.enqueueMsg(&m);
    }
    
    event void Measure.stopped(void) {
		call NodeTools.debugPrint("Measure stopped.");
    }
}
