configuration LcdDispC
{
    provides interface LcdDisp;
}

implementation
{
    components LcdDispP as App;
    LcdDisp = App;

    components MainC;
    App.Boot -> MainC;

    components new TimerMilliC() as Timer;
    App.Timer -> Timer;

    // Komponenten und Wiring fuer UART
    components new Msp430Uart0C() as UartC;

    App.Resource -> UartC.Resource;
    App.UartStream -> UartC.UartStream;
    App.Msp430UartConfigure <- UartC.Msp430UartConfigure;
}
