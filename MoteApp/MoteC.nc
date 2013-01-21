// Das vi-Syntaxhighlighting funktioniert (bei mir) nur mit diesem seltsamen Kommentar-Konstrukt am Anfang.

/**
**/

#include "allnodes.h"
#include "pack.h"

module MoteC {
    uses {
        interface NodeTools;
        interface Boot;
        interface Measure;
		interface LcdMenu as Lcd;
    }
}

implementation {
	uint8_t myID; // eigene ID, festgelegt in booted()
	uint8_t partnerID; // Messpartner, festgelegt bei CMD_NEWMEASURE
	uint16_t measureSet; // Messreihe, dito
	uint32_t startTime; // Startzeit, dito
	node_msg_t lcdCommand;

	/* Prototypes */
	void handleCommand(node_msg_t *msg);

    event void Boot.booted(void) {
        call NodeTools.serialInit();
		myID = call NodeTools.myAddress();
		// Andis LCD ansprechen
		call Lcd.getUserCmd(&lcdCommand);
    }
    
	/* Empfängt Kommandos vom LCD. */
	event void Lcd.cmd_msg_ready(node_msg_t *cmd) {
		handleCommand(cmd);
		call Lcd.getUserCmd(&lcdCommand);
	}

	/* Empfängt alle Kommandos, die NodeToolsP 
	 * nicht selbst behandeln kann. */
    event void NodeTools.onSerialCommand(node_msg_t* cmd) {
		handleCommand(cmd);
	}
	// Dissemination receive event handler

    event void Measure.setupDone(error_t error) {
    }

    void handleCommand(node_msg_t* cmd) {
		struct measure_options opts;
        
		switch (cmd->cmd) {
			case CMD_NEWMEASURE:
				if (myID == cmd->data[0]) {
					partnerID = cmd->data[1];
					measureSet = (uint16_t) makeWORD(cmd->data, 2);
					startTime = (uint32_t) makeDWORD(cmd->data, 4);
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
					call Measure.start();
				} else {
					call NodeTools.debugPrint("startms dissemination");
					// Nachricht ist nicht für mich selbst - per dissemination weiterleiten
				}

				call NodeTools.serialSendOK();
				break;

			case CMD_STOPMS:
				if (myID == cmd->data[0] && partnerID == cmd->data[1]) {
					call Measure.stop();
				} else {
					call NodeTools.debugPrint("stopms dissemination");
					// Nachricht ist nicht für mich selbst - per dissemination weiterleiten
				}

				call NodeTools.serialSendOK();
				break;

			case CMD_CLEARMS:
				if (myID == cmd->data[0] && partnerID == cmd->data[1]) {
					// not implemented (setup, stop und start verwenden)
				} else {
					call NodeTools.debugPrint("clearms dissemination");
					// Nachricht ist nicht für mich selbst - per dissemination weiterleiten
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
    event void Measure.received(uint8_t rssi) {
		node_msg_t m;
		uint8_t i;

		m.cmd = CMD_REPORT;
		m.data[0] = myID;

		// Messreihe: data[1...2]
		m.data[1] = measureSet;
		m.data[2] = measureSet >> 8;

		// Timestamp: data[3...6]
		for (i = 0; i < 4; i++) {
			m.data[3+i] = 0; //time >> (8 * i);
		}
		m.data[7] = rssi;
		m.data[8] = partnerID;
		m.length = 9;
		m.moreData = 0;

		// Report an die MoteConsole senden
		call NodeTools.enqueueMsg(&m);
		// Report an das LCD senden
		call Lcd.showReport(&m);
    }
    
    event void Measure.stopped(void) {
		call NodeTools.debugPrint("Measure stopped.");
    }
}