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

	components NodeCommC;
	App.NodeComm -> NodeCommC;
}
