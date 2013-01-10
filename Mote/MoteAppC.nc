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

	components CollectionC;
	App.CollectionControl -> CollectionC;
	components new CollectionSenderC(COLLECT);
	App.CollectionSend -> CollectionSenderC;

	components DisseminationC;
	App.DissControl -> DisseminationC;
	components new DisseminatorC(nx_struct Settings, DISSEMINATE);
	App.Settings -> DisseminatorC;
	
	components CC2420PacketC;
	App.RssiPacket -> CC2420PacketC;
}
