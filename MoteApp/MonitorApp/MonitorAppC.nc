// vim: filetype=nc:tabstop=4:expandtab:shiftwidth=0:softtabstop=-1

//

/**
**/

#include "../allnodes.h"

configuration MonitorAppC {
}
implementation {
	components Monitor as App;
	
	components MainC;
	App.Boot -> MainC.Boot;
	
	components LcdMenuC;
	App.LcdMenu -> LcdMenuC;

   components CC2420ActiveMessageC as RadioAM;
	App.AMPacket -> RadioAM.AMPacket;
	App.AMSend -> RadioAM.AMSend[AM_NODE_MSG];
	App.Receive -> RadioAM.Receive[AM_NODE_MSG];
	App.RadioControl -> RadioAM;
}
