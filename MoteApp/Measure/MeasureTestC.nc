#include "../allnodes.h"

configuration MeasureTestC {
} implementation {
    components MeasureTestAppC as TestApp;

    components MainC;	
    TestApp.Boot -> MainC.Boot;

    components NodeToolsC;
    TestApp.NodeTools -> NodeToolsC;

    components new Timer<TMilli>() as Timer;
    TestApp.Timer = Timer;

    components MeasureC;
    TestApp.Measure -> MeasureC;
}
