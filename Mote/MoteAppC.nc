#include "../Rssi.h"

configuration MoteAppC
{
}

implementation
{
	components MoteC as App;

    components MainC;
    App.Boot -> MainC.Boot;

	components LedsC;
	App.Leds -> LedsC;

	components ActiveMessageC as Radio;
	App.RadioControl -> Radio;

	components new TimerMilliC() as Timer;
	App.BeaconTimer -> Timer;

	components new AMSenderC(AM_BEACONMSG);
    components new AMReceiverC(AM_BEACONMSG);
	App.BeaconSend -> AMSenderC;
	App.BeaconReceive -> AMReceiverC;

	components new CollectionSenderC(AM_COLLECT);
	App.CollectionSend -> CollectionSenderC;
	
	components CC2420PacketC;
	App.RssiPacket -> CC2420PacketC;
}
