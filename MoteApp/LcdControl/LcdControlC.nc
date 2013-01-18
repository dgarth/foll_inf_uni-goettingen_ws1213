configuration LcdControlC
{
    provides interface LcdControl;
}

implementation
{
    components LcdControlP as App;
    LcdControl = App;
    // Komponenten und Wiring fuer UART
    components new Msp430Uart1C() as UartC;
    
    components LedsC;
    App.Leds -> LedsC;

    components new AlarmMilli32C() as Alarm;
    App.Alarm -> Alarm;

    App.Resource -> UartC.Resource;
    App.UartStream -> UartC.UartStream;
    //App.UartByte -> UartC.UartByte;
    App.Msp430UartConfigure <- UartC.Msp430UartConfigure;
}
