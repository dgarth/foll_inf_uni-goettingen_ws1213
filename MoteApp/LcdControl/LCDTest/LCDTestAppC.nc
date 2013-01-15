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

    components new TimerMilliC() as Timer;
    App.Timer -> Timer;

    components LcdControlC;
    App.LcdControl -> LcdControlC;
}
