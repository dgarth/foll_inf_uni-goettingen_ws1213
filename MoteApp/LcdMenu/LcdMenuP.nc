#include "allnodes.h"
#include <string.h>

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
		
		char *id1 = "N1:";
		char *id2 = "N2:";
		char *mid = "M:";
		char *rssi = "R:";
		char *t = "T:";
		uint16_t mr = 0;
		uint32_t time = 0;
		uint8_t i;
		
		r = TRUE;
		rep_msg = report;
		
		if(rep_msg->cmd != CMD_REPORT)
			return FAIL;
		
		// Hier folgt: DIE STRINGHOELLE
		
		//Initialisieren
		memset(linebuf1, ' ', 16);
		memset(linebuf2, ' ', 16);
		
		//Labels kopieren
		strncpy(linebuf1, id1, 3);
		strncpy((linebuf1+6), id2, 3);
		strncpy((linebuf1+12), mid, 2);
		strncpy(linebuf2, rssi, 2);
		strncpy(linebuf2+6, t, 2);
		
		//Werte umwandeln und in die Buffer schreiben
		itoa(rep_msg->data[0], linebuf1+3, 10);
		itoa(rep_msg->data[8], linebuf1+9, 10);
		mr = (rep_msg->data[1] * 256) | rep_msg->data[2];
		time = (rep_msg->data[3] * 256*256*256) | (rep_msg->data[4] * 256*256) | (rep_msg->data[5] * 256)| rep_msg->data[6];
		itoa(mr, linebuf1+14, 10);
		itoa(rep_msg->data[7], linebuf2+2, 10);
		itoa(time, linebuf2+8, 10);
		for(i=0;i<16;i++) {
			if(linebuf1[i]=='\0')
				linebuf1[i]=' ';
			if(linebuf2[i]=='\0')
				linebuf2[i]=' ';	
		}
		
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