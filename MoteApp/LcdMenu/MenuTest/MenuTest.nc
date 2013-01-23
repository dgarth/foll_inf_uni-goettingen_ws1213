//vim: filetype=nc:tabstop=4:expandtab:shiftwidth=0:softtabstop=-1

#include "allnodes.h"

module MenuTest
{
    uses {
    	interface Boot;
        interface Leds;
        interface LcdMenu;
    }
}

implementation
{
	node_msg_t myMsg, menuMsg;
    event void Boot.booted() {
    	uint8_t i;
    	myMsg.cmd = 0;
    	myMsg.length = 0;
    	for(i=0; i<MAX_DATA; i++)
    		myMsg.data[i]=0;
    	myMsg.moreData = 0;
    	//call LcdMenu.getUserCmd(&myMsg);
    	
    	myMsg.cmd = CMD_REPORT;
    	myMsg.length = 9;
    	myMsg.data[0]=1;
    	myMsg.data[1]=0x00;
    	myMsg.data[2]=0x04;
    	myMsg.data[6]=134;
    	myMsg.data[7]=32;
    	myMsg.data[8]=2;
    	
    	call LcdMenu.getUserCmd(&menuMsg);
    }
    
    event void LcdMenu.cmd_msg_ready(node_msg_t *cmd) {
    	myMsg.data[0]=cmd->data[0];
    	myMsg.data[1]=cmd->data[2];
    	myMsg.data[2]=cmd->data[3];
    	myMsg.data[8]=cmd->data[1];
    	call LcdMenu.showReport(&myMsg);
    }

}
