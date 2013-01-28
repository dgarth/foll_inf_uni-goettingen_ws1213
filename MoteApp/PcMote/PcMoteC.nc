// vim: filetype=nc:tabstop=4:expandtab

// Das vi-Syntaxhighlighting funktioniert (bei mir) nur mit diesem seltsamen Kommentar-Konstrukt am Anfang.

/**
 **/

#include "allnodes.h"
#include "pack.h"

module PcMoteC {
    uses {
        interface NodeTools; // Konsolensteuerung
        interface Boot;
		interface NodeComm; // Collection & Dissemination
    }
}

implementation {

    /* Prototypes */
    void handleCommand(node_msg_t *msg);

    event void Boot.booted(void) {
		call NodeComm.init();
        call NodeTools.serialInit();
    }


    /* 
     * Wenn ein Kommando von der Konsole empfangen wird,
     * soll es lediglich ueber Disseminaton weitergeleitet werden?!
     */
    event void NodeTools.onSerialCommand(node_msg_t* cmd) {
        handleCommand(cmd);
    }

	/*
     * Der PcMote sollte eigentlich nichts machen, wenn er 
     * ueber Dissemination was bekommt?!
     */
	event void NodeComm.dissReceive(const node_msg_t* cmd) {
		//handleCommand(cmd);
	}

    /* 
     * Schickt cmd einfach weiter ueber dissSend
     */
    void handleCommand(node_msg_t* cmd) {
        call NodeComm.dissSend(cmd);
        call NodeTools.serialSendOK();
    }

	/* 
     * Report per Collection empfangen. An die MoteConsole
	 * senden und/oder auf dem LCD ausgeben.
     */
	event void NodeComm.collReceive(node_msg_t* msg) {
        call NodeTools.enqueueMsg(msg);
	}

}
