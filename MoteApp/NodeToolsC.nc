/* NodeToolsC.nc - Konfiguration und Wirings für das Interface NodeTools */

configuration NodeToolsC {
	provides interface NodeTools;
}

implementation {
	components NodeToolsP; /* hier wird NodeTools implementiert */
	NodeTools = NodeToolsP;

	components PrintfC;
	components SerialStartC;

	components LedsC;
	NodeToolsP.Leds -> LedsC;

	components new TimerMilliC() as BlinkTimer0;
	components new TimerMilliC() as BlinkTimer1;
	components new TimerMilliC() as BlinkTimer2;
	NodeToolsP.TBlinkLed0 -> BlinkTimer0;
	NodeToolsP.TBlinkLed1 -> BlinkTimer1;
	NodeToolsP.TBlinkLed2 -> BlinkTimer2;

	components SerialActiveMessageC as SerialAM;
	NodeToolsP.SerialAMCtrl -> SerialAM;
	NodeToolsP.SerialReceive -> SerialAM.Receive[AM_NODE_MSG];
	NodeToolsP.SerialAMSend -> SerialAM.AMSend[AM_NODE_MSG];
	NodeToolsP.SerialPacket -> SerialAM;

	components CC2420ActiveMessageC as RadioAM;
	NodeToolsP.AMPacket -> RadioAM;
}

