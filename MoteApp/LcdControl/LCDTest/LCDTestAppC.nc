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
