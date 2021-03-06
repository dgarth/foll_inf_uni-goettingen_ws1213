// vim: filetype=nc:tabstop=4:expandtab:shiftwidth=0:softtabstop=-1

#include "../allnodes.h"
#include "../pack.h"
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
	uint8_t cmdType = CMD_NEWMS, phase = 0, id1 = 1, id2 = 1;
	uint16_t quantity = 1, mid = 0;
	uint32_t time = 0;
	
	//Wenn wir fertig sind mit dem Menue, schmeissen wir dieses event
	task void done(void) {
		signal LcdMenu.cmd_msg_ready(cmd_msg);
	}
	
	//initialisieren der Msg
	void msg_init(void) {
		uint8_t i;
		cmd_msg->cmd = 0;
		cmd_msg->length = 17;
		for(i=0; i<MAX_DATA; i++)
			cmd_msg->data[i]=0;
		cmd_msg->moreData = 0;
	}
	
	//Ausgabe des einzustellenden Wertes auf Disp
	void getId1(void) {
		sprintf(linebuf1, "n1: %u", id1);
	}
	
	void getId2(void) {
		sprintf(linebuf2, "n2: %u", id2);
	}
	
	void getMid(void) {
		sprintf(linebuf1, "mr: %u", mid);
	}
	
	void getQuantity(void) {
		sprintf(linebuf1, "Quantity:");
		sprintf(linebuf2, "%u", quantity);
	}
	
	void getCmdType(void) {
		switch(cmdType) {
			case CMD_NEWMS:
				sprintf(linebuf1, "Cmd: CMD_NEWMS");
			break;
			case CMD_STARTMS:
				sprintf(linebuf1, "Cmd: CMD_STARTMS");
			break;
			case CMD_STOPMS:
				sprintf(linebuf1, "Cmd: CMD_STOPMS");
			break;
		}
	}
	
	//Wenn wir alle Werte haben, in die fertige node_msg_t schreiben
	void finalize(void) {
		cmd_msg->cmd = cmdType;
		cmd_msg->length = pack(cmd_msg->data, "BBHH",
				id1,
				id2,
				mid,
				quantity
				);
	}
	
	/*Einen Befehl vom User erfragen und entsprechende node_msg_t generieren*/
	command void LcdMenu.getUserCmd(node_msg_t *cmd)
	{
		cmd_msg = cmd;
		c = TRUE;
		switch(phase) {
			case 0:
				msg_init();
				getCmdType();
				call LcdControl.enable();
			break;
			case 1:
				getId1();
			break;
			case 2:
				getId2();
			break;
			case 3:
				getMid();
			break;
			case 4:
				getQuantity();
			break;
			case 5:
				call LcdControl.puts("OK", 1);
				c = FALSE;
				finalize();
				call LcdControl.disable();
				post done();
				phase = 0;
			break;
			default:
			break;
		}
		
	}
	
	/*Einen Messreport aus einer node_msg_t über den LCD anzeigen */
	command error_t LcdMenu.showReport(const node_msg_t *report)
	{
		int8_t rssi;
		uint16_t series_nr, packet_nr;
		
		r = TRUE;
		rep_msg = report;
		
		if(rep_msg->cmd != CMD_REPORT)
			return FAIL;
		
		memset(linebuf1, ' ', 16);
		memset(linebuf2, ' ', 16);
		
		unpack(rep_msg->data, "BBHHb",
				&id1,
				&id2,
				&series_nr,
				&packet_nr,
				&rssi
			  );
		
		snprintf(linebuf1, 16, "N1:%u N2:%u M:%u", id1, id2, series_nr);
		snprintf(linebuf2, 16, "P:%u R:%d", packet_nr, rssi);
		
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
		} else if(c) {//oder den Anfang des Menues
			call LcdControl.puts(linebuf1, 1);
			call LcdControl.puts(linebuf2, 2);
		}
	}
	
	//Button 1 ist zum einstellen der Werte
	event void LcdControl.button1Pressed()
	{
		if(c) {
			//Aufteilung in "Phasen", 1 Phase pro einzustellendem Wert
			switch(phase) {
				case 0:
					cmdType++;
					if(cmdType > CMD_STOPMS)
						cmdType = CMD_NEWMS;
					getCmdType();
				break;
				case 1:
					id1++;
					if(id1 > 6)
						id1 = 1;
					getId1();
				break;
				case 2:
					id2++;
					if(id2 > 6)
						id2 = 1;
					getId2();
				break;
				case 3:
					mid++;
					getMid();
				break;
				case 4:
					if(!quantity)
							quantity=1;
					else
						quantity = quantity<<1;
				
					getQuantity();
				break;
			}
			call LcdControl.puts(linebuf1, 1);
			call LcdControl.puts(linebuf2, 2);
		}
	}
	
	//Button 2 ist die "OK"-Taste
	event void LcdControl.button2Pressed()
	{
		if(c) {
			phase++;
			//Falls wir Start/Stopp-Cmd eingeben, brauchen wir nur ID1 und ID2 zu fragen:
			if((phase > 2) && (cmdType != CMD_NEWMS)) {
				phase = 5;
				cmd_msg->length = 2;
			}
			
			//Naechste Phase starten:
			call LcdMenu.getUserCmd(cmd_msg);
			call LcdControl.puts(linebuf1, 1);
			call LcdControl.puts(linebuf2, 2);
		}
	}
}
