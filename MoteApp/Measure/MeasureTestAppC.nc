// vim: filetype=nc:tabstop=4:expandtab:shiftwidth=0:softtabstop=-1

configuration MeasureTestAppC
{
}

implementation
{
    components MeasureTestC as TestApp;

    components MainC;
    TestApp.Boot -> MainC;

    components NodeToolsC;
    TestApp.NodeTools -> NodeToolsC;

    components MeasureC;
    TestApp.Measure -> MeasureC;
}
