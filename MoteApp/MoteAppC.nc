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
}
