configuration TestRssiC {}

implementation {
	
	components TestRssiP as App,
		MainC,
		ActiveMessageC,
		CC2420ActiveMessageC,
		new AMSenderC(128),
		new AMReceiverC(128),
		new TimerMilliC(),
		LedsC;
		
	App.Boot -> MainC;
	App.SplitControl -> ActiveMessageC;
	App.Leds -> LedsC;
	App.AMSend -> AMSenderC;
	App.Receive -> AMReceiverC;
	App.PacketAcknowledgements -> ActiveMessageC;
	App.Timer -> TimerMilliC;
	App.CC2420Packet -> CC2420ActiveMessageC;
	
	// Komponenten und Wiring fuer UART
	components new Msp430Uart0C() as UartC;
	
	App.Resource				-> UartC.Resource;
	App.UartStream				-> UartC.UartStream;
	App.Msp430UartConfigure		<- UartC.Msp430UartConfigure;
	
}
