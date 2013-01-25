//vim: filetype=nc:tabstop=4:expandtab:shiftwidth=0:softtabstop=-1

configuration LcdTestAppC
{
}

implementation
{
    components LcdTest as App;

    components MainC;
    App.Boot -> MainC.Boot;

    components LedsC;
    App.Leds -> LedsC;
    
    components LcdControlC;
    App.LcdControl -> LcdControlC;
}
