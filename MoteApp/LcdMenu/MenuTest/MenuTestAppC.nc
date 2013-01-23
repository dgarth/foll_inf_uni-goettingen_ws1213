// vim: filetype=nc:tabstop=4:expandtab:shiftwidth=0:softtabstop=-1

configuration MenuTestAppC
{
}

implementation
{
    components MenuTest as App;

    components MainC;
    App.Boot -> MainC.Boot;

    components LedsC;
    App.Leds -> LedsC;
    
    components LcdMenuC;
    App.LcdMenu -> LcdMenuC;
}
