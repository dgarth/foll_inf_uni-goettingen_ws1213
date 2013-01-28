// vim: filetype=nc:tabstop=4:expandtab:shiftwidth=0:softtabstop=-1

/* NodeCommC.nc - Konfiguration und Wirings für das Interface NodeComm */

configuration NodeCommC {
	provides interface NodeComm;
}

implementation {
	components NodeCommP; /* hier wird NodeComm implementiert */
	NodeComm = NodeCommP;

	components NodeToolsC, LedsC;
	NodeCommP.NodeTools -> NodeToolsC;
	NodeCommP.Leds -> LedsC;

	// Radio control
	components ActiveMessageC;
	NodeCommP.AMControl -> ActiveMessageC;

	// Dissemination control
	components DisseminationC;
	NodeCommP.DisControl -> DisseminationC;

	// DisseminatorC(Datentyp, Key); jeder Datentyp braucht seinen eigenen Key
	components new DisseminatorC(node_msg_t, AM_DISS_NODEMSG) as DisMsg;
	NodeCommP.DisMsg -> DisMsg;
	NodeCommP.DisUpdate -> DisMsg;

	// Collection
	components CollectionC as Collector;
	components new CollectionSenderC(AM_COLLECTION);
	NodeCommP.RoutingControl -> Collector;
	NodeCommP.ColSend -> CollectionSenderC;
	NodeCommP.ColReceive -> Collector.Receive[AM_COLLECTION];
	NodeCommP.RootControl -> Collector;

    // Forward Sink zu Monitor
    components new AMSenderC(AM_MONITOR);
    components new AMReceiverC(AM_MONITOR);
    NodeCommP.MonitorSend -> AMSenderC;
    NodeCommP.MonitorReceive -> AMReceiverC;
}

