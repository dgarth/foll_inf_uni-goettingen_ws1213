// vim: filetype=nc:tabstop=4:expandtab:shiftwidth=0:softtabstop=-1

#include "../allnodes.h"

configuration MeasureMoteAppC
{
}
implementation
{
    components MeasureMoteC as App;

    components MainC;
    App.Boot -> MainC.Boot;

    components NodeCommC;
    App.NodeComm -> NodeCommC;

    components MeasureC;
    App.Measure -> MeasureC;
}
