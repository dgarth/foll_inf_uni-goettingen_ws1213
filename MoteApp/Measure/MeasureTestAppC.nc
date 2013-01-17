#include "allnodes.h"

configuration MeasureTestAppC {
} implementation {
    components MeasureTestC as TestApp;

    components MainC, LedsC;
    TestApp.Boot -> MainC;
    TestApp.Leds -> LedsC;

    components NodeToolsC;
    TestApp.NodeTools -> NodeToolsC;

    /*components new Timer<TMilli>() as Timer;
    TestApp.Timer = Timer;*/

    components MeasureC;
    TestApp.Measure -> MeasureC;
}
