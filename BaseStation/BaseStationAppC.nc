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
    App.CollectionControl -> CollectionC;
    App.CollectionReceive -> CollectionC.Receive[COLLECT];

    components DisseminationC;
    App.DissControl -> DisseminationC;
    components new DisseminatorC(nx_struct Settings, DISSEMINATE);
    App.Settings -> DisseminatorC;

    components SerialActiveMessageC as Serial;
    components new SerialAMSenderC(AM_RSSIMSG) as SerialSend;
    App.SerialControl -> Serial;
    App.SerialSend -> SerialSend;

    components new TimerMilliC();
    App.Timer -> TimerMilliC;
}
