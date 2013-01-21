#include "allnodes.h"
#include "pack.h"
#include <string.h>
#include <stdio.h>

module LcdMenuP
{
    provides {
        interface LcdMenu;
    }

    uses {
        interface LcdControl;
    }
}

implementation {
	node_msg_t *cmd_msg;
	const node_msg_t *rep_msg;
	char linebuf1[16], linebuf2[16];
	bool c = FALSE,
		r = FALSE;
	
	/*TODO: Einen Befehl vom User erfragen und entsprechende node_msg_t generieren*/
	command error_t LcdMenu.getUserCmd(node_msg_t *cmd)
	{
		 cmd_msg = cmd;
		 
		 //TODO Input Menu
		 
		 return SUCCESS;
	}
	
	/*DONE: Einen Messreport aus einer node_msg_t über den LCD anzeigen */
	command error_t LcdMenu.showReport(const node_msg_t *report)
	{
		uint16_t mr = 0;
		uint32_t time = 0;
		
		r = TRUE;
		rep_msg = report;
		
		if(rep_msg->cmd != CMD_REPORT)
			return FAIL;
		
		memset(linebuf1, ' ', 16);
		memset(linebuf2, ' ', 16);
		
		unpack((uint8_t*) rep_msg->data+1, "H", &mr);
		unpack((uint8_t*) rep_msg->data+3, "I", &time);
		
		snprintf(linebuf1, 16, "N1:%u N2:%u M:%u", rep_msg->data[0], rep_msg->data[8], mr);
		snprintf(linebuf2, 16, "R:%u T:%lu", rep_msg->data[7], time);
		/*
		for(i=0;i<16;i++) {
			if(linebuf1[i]=='\0')
				linebuf1[i]=' ';
			if(linebuf2[i]=='\0')
				linebuf2[i]=' ';	
		}
		*/
		//LCD anschalten
		call LcdControl.enable();
		return SUCCESS;
	}
	
	
	/* Wenn der LCD gefunden wurde */
	event void LcdControl.lcdEnabled()
	{	
		//drucken wir einen Report drauf aus
		if(r) {
			r = FALSE;
			call LcdControl.beep();
			call LcdControl.puts(linebuf1, 1);
			call LcdControl.puts(linebuf2, 2);
			call LcdControl.disable();
		} else if(c) {//oder TODO: das Menue
		
		}
	}
	
	event void LcdControl.button1Pressed()
	{
	
	}
	
	event void LcdControl.button2Pressed()
	{
	
	}
}