//vim: filetype=nc:tabstop=4:expandtab:shiftwidth=0:softtabstop=-1

configuration RelayAppC {
}

implementation {
	/*** eigene Komponenten ***/
	components RelayC;
	components NodeToolsC;
	RelayC.Tools -> NodeToolsC;

	/*** externe Komponenten ***/

	/* allgemein */
	components PrintfC;
	components SerialStartC;

	/* Boot-Interface */
	components MainC;
	RelayC.Boot -> MainC;

	/* Timer */
	components new TimerMilliC() as AckTimer;
	RelayC.TAckRequest -> AckTimer;

	/** RF-Transmission **/

	/* Der Parameter von AMSenderC ist der "AM type".
	 * Die Multiplex-Schicht benutzt diesen Wert, um
	 * verschiedene Datenströme aus dem Funkverkehr
	 * auseinanderzuhalten. Sender und Empfänger, die
	 * kommunizieren sollen, benötigen daher denselben
	 * Wert. */
	components new AMSenderC(6);
	RelayC.AMSend -> AMSenderC;
	RelayC.Packet -> AMSenderC;
	RelayC.AMPacket -> AMSenderC;

	/* Es darf in einer App keine zwei AMReceiverC mit
	 * demselben AM type geben. */
	components new AMReceiverC(6);
	RelayC.Receive -> AMReceiverC;

	/* TelosB-Nodes haben einen CC2420-Chip von TI (mit
	 * eigener Implementierung von ActiveMessageC).
	 * Diese Komponente kann den RF-Chip hochfahren
	 * (und auch wieder runterfahren). */
	components CC2420ActiveMessageC as RFCtrl;
	RelayC.AMControl -> RFCtrl;
	RelayC.PackAcks -> RFCtrl;

}
