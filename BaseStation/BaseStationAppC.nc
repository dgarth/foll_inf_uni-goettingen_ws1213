#include "../Rssi.h"

configuration BaseStationAppC
{
}

implementation
{
	components BaseStationC as App;

    components MainC;
    App.Boot -> MainC.Boot;

	components LedsC;
	App.Leds -> LedsC;

	components ActiveMessageC as Radio;
	App.RadioControl -> Radio;

	components CollectionC;
	App.RootControl -> CollectionC;
	App.CollectionReceive -> CollectionC.Receive[AM_COLLECT];

	components SerialActiveMessageC as Serial;
	components new SerialAMSenderC(AM_RSSIMSG) as SerialSend;
	App.SerialControl -> Serial;
	App.SerialSend -> SerialSend;
}