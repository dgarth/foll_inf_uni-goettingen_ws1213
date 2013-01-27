// vim: filetype=nc:tabstop=4:expandtab:shiftwidth=0:softtabstop=-1

// Das vi-Syntaxhighlighting funktioniert (bei mir) nur mit diesem seltsamen Kommentar-Konstrukt am Anfang.

/**
 **/

#include "allnodes.h"
#include "pack.h"
#include <string.h>

module Monitor {
    uses {
       interface AMSend;
       interface Receive;
       interface AMPacket;
       interface LcdMenu;
       interface SplitControl as RadioControl;
       interface Boot;
    }
}

implementation {
	node_msg_t cmd_msg, *report_msg;
	message_t sPacket;

	event void Boot.booted(void) {
		call RadioControl.start();
	}
	
	event void AMSend.sendDone(message_t *msg, error_t error) {
		call LcdMenu.getUserCmd(&cmd_msg);
	}
	
	event message_t* Receive.receive(message_t *msg, void *payload, uint8_t len) {
		report_msg = (node_msg_t*) payload;
		if(report_msg->cmd == CMD_REPORT)
			call LcdMenu.showReport(report_msg);
		
		return msg;
	}
	
	event void LcdMenu.cmd_msg_ready(node_msg_t *cmd) {
		node_msg_t *pmsg;
		pmsg = call AMSend.getPayload(&sPacket, sizeof(node_msg_t));
		
		memcpy(pmsg, cmd, sizeof(node_msg_t));
		
		call AMSend.send(AM_BROADCAST_ADDR, &sPacket, sizeof(node_msg_t));	
	}
	
	event void RadioControl.startDone(error_t error) {
		call LcdMenu.getUserCmd(&cmd_msg);
	}
	
	event void RadioControl.stopDone(error_t error) {
	}
}
