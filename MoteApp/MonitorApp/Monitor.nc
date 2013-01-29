// vim: filetype=nc:tabstop=4:expandtab:shiftwidth=0:softtabstop=-1

// Das vi-Syntaxhighlighting funktioniert (bei mir) nur mit diesem seltsamen Kommentar-Konstrukt am Anfang.

/**
 **/

#include "allnodes.h"
#include "pack.h"
#include <string.h>

module Monitor {
    uses {
       interface NodeComm;
       interface LcdMenu;
       interface Boot;
    }
}

implementation {
	node_msg_t cmd_msg[2];
	uint8_t i = 0;
	
	event void Boot.booted(void) 
	{
		call NodeComm.init();
		call LcdMenu.getUserCmd(&(cmd_msg[i]));
	}
	
	event void NodeComm.dissReceive(const node_msg_t* cmd) 
	{}
	
	event void NodeComm.collReceive(node_msg_t* msg) {
		if(msg->cmd == CMD_REPORT)
			call LcdMenu.showReport(msg);
	}
	
	event void LcdMenu.cmd_msg_ready(node_msg_t* cmd) {
		call NodeComm.dissSend(cmd);
		i = (i+1)%2;
		call LcdMenu.getUserCmd(&(cmd_msg[i]));
	}
}
