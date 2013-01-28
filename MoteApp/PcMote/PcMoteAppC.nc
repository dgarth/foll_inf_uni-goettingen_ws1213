// vim: filetype=nc:tabstop=4:expandtab:shiftwidth=0

/**
**/

#include "../allnodes.h"

configuration PcMoteAppC {
}
implementation {
    components PcMoteC as App;

    components MainC;	
    App.Boot -> MainC.Boot;

    components NodeToolsC;
    App.NodeTools -> NodeToolsC;

	components NodeCommC;
	App.NodeComm -> NodeCommC;
}
