// vim: filetype=nc:tabstop=4:expandtab:shiftwidth=0:softtabstop=-1

// Das vi-Syntaxhighlighting funktioniert (bei mir) nur mit diesem seltsamen Kommentar-Konstrukt am Anfang.

/**
 **/

#include "allnodes.h"
#include "pack.h"

module MoteC {
    uses {
        interface NodeTools; // Konsolensteuerung
        interface Boot;
        interface Measure;
        interface LcdMenu as Lcd;
		interface NodeComm; // Collection & Dissemination
    }
}

implementation {
    uint16_t measureSet; // Messreihe
    struct measure_options measureOpts; // Messoptionen
    node_msg_t lcdCommand;

    /* Prototypes */
    void handleCommand(const node_msg_t *msg);

    event void Boot.booted(void) {
		call NodeComm.init();
//#ifdef PCMOTE
        call NodeTools.serialInit();
//#endif
//#ifdef LCDMOTE
        call Lcd.getUserCmd(&lcdCommand);
//#endif
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

	/* Empfängt Kommandos, die von anderen Nodes per
	 * Dissemination weitergeleitet wurden */
	event void NodeComm.dissReceive(const node_msg_t* cmd) {
		handleCommand(cmd);
	}

	event void Measure.setupDone(error_t error) {
    }

    void handleCommand(const node_msg_t* cmd) {
        uint8_t id1, id2;
        bool cmd_ok = FALSE;

        /* is the command related to a measure? */
        switch (cmd->cmd) {
            case CMD_NEWMEASURE:
            case CMD_STARTMS:
            case CMD_STOPMS:
                cmd_ok = TRUE;
                break;
            default:
                call NodeTools.debugPrint("WARN: Undefined command.");
        }

        /* am I involved in the measure? */
        if (cmd_ok) {
            unpack(cmd->data, "BB", &id1, &id2);
            if (TOS_NODE_ID != id1 && TOS_NODE_ID != id2) {
                cmd_ok = FALSE;
            }
        } //TODO else: NodeComm.dissSend(cmd) // Kommando im Netzwerk verteilen (ALLE, nicht nur messbezogene!)

        /* the answer to either of the above was NO -> do nothing */
        if (!cmd_ok) {
            call NodeTools.serialSendOK();
            return;
        }

        switch (cmd->cmd) {
            case CMD_NEWMEASURE:
                unpack(cmd->data, "__HHH",
                        &measureSet,
                        &measureOpts.count//,
                        //&measureOpts.interval
                      );

                measureOpts.partner = (TOS_NODE_ID == id1) ? id2 : id1;
                call Measure.setup(measureOpts);
                break;

            case CMD_STARTMS:
                call Measure.start();
                break;

            case CMD_STOPMS:
                call Measure.stop();
                break;
        }
        call NodeTools.serialSendOK();
    }

    /* Neue Messung empfangen - Report senden */
    event void Measure.received(int8_t rssi) {
        node_msg_t m;

        m.cmd = CMD_REPORT;

        m.length = pack(m.data, "BBHHb",
                TOS_NODE_ID,
                measureOpts.partner,
                measureSet,
                0,
                rssi
                );

        m.moreData = 0;

        // Report an die MoteConsole senden
        call NodeTools.enqueueMsg(&m);
        // Report an das LCD senden
        call Lcd.showReport(&m);
		// Report per Collection senden
		call NodeComm.collSend(&m);
    }

	/* Report per Collection empfangen. An die MoteConsole
	 * senden und/oder auf dem LCD ausgeben. */
	event void NodeComm.collReceive(node_msg_t* msg) {
        call NodeTools.enqueueMsg(msg);
        call Lcd.showReport(msg);
	}

    event void Measure.stopped(void) {
        call NodeTools.debugPrint("Measure stopped.");
    }
}
