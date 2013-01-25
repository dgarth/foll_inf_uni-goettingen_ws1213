//vim: filetype=nc:tabstop=4:expandtab:shiftwidth=0:softtabstop=-1

//

/**
**/

#include "../allnodes.h"

configuration MoteAppC {
}
implementation {
    components MoteC as App;

    components MainC;	
    App.Boot -> MainC.Boot;

    components NodeToolsC;
    App.NodeTools -> NodeToolsC;

    components MeasureC;
    App.Measure -> MeasureC;

	components LcdMenuC;
	App.Lcd -> LcdMenuC;
}
