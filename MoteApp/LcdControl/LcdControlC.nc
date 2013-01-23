//vim: filetype=nc:tabstop=4:expandtab:shiftwidth=0:softtabstop=-1

configuration LcdControlC
{
    provides interface LcdControl;
}

implementation
{
    components LcdControlP as App;
    LcdControl = App;
    
    components LedsC;
    App.Leds -> LedsC;

    components new AlarmMilli32C() as Alarm;
    App.Alarm -> Alarm;
    
    // Komponenten und Wiring fuer UART
    components new Msp430Uart0C() as UartC;

    App.Resource -> UartC.Resource;
    App.UartStream -> UartC.UartStream;
    
    App.Msp430UartConfigure <- UartC.Msp430UartConfigure;
}
