/* NodeToolsC.nc - Konfiguration und Wirings für das Interface NodeTools */

configuration NodeToolsC {
	provides interface NodeTools;
}

implementation {
	components NodeToolsP; /* hier wird NodeTools implementiert */
	components LedsC;
	components new TimerMilliC() as BlinkTimer0;
	components new TimerMilliC() as BlinkTimer1;
	components new TimerMilliC() as BlinkTimer2;

	NodeTools = NodeToolsP;

	NodeToolsP.Leds -> LedsC;
	NodeToolsP.TBlinkLed0 -> BlinkTimer0;
	NodeToolsP.TBlinkLed1 -> BlinkTimer1;
	NodeToolsP.TBlinkLed2 -> BlinkTimer2;
}

