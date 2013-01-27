// vim: filetype=nc:tabstop=4:expandtab:shiftwidth=0:softtabstop=-1

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
    
    // Komponenten und Wiring fuer UART, im Makefile -DUSE_UART0 oder -DUSE_UART1 zum waehlen der Schnittstelle
    #if defined USE_UART0 && defined USE_UART1
    	#error "Please specify only one UART, where the LCD will be connected!"
    #elif defined USE_UART0
    	components new Msp430Uart0C() as UartC;
    #elif defined USE_UART1
    	components new Msp430Uart1C() as UartC;
    #else 
    	#error "Please define which UART to use for the LCD!"
	#endif
	
    App.Resource -> UartC.Resource;
    App.UartStream -> UartC.UartStream;
    
    App.Msp430UartConfigure <- UartC.Msp430UartConfigure;
}
