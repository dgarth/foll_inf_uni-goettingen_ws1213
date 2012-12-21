#include "Horst.h"

configuration HorstAppC
{
}
implementation
{
	components HorstC as App;

    components MainC, LedsC;

	components SendRssiC;

	components new TimerMilliC() as Timer0;

	components ActiveMessageC as Radio;
    components SerialActiveMessageC as Serial;

    components new SerialAMSenderC(AM_SERIALMSG);

    components new AMSenderC(AM_RADIOMSG);
    components new AMReceiverC(AM_RADIOMSG);

	components CC2420PacketC;

    App.Boot -> MainC.Boot;

    App.Leds -> LedsC;

	App.Timer0 -> Timer0;

	App.RadioControl -> Radio;

	App.SendRssi -> SendRssiC;
	App.SendRssiControl -> SendRssiC.SplitControl;

	SendRssiC.SendingChannelControl -> Serial;
	SendRssiC.Packet -> Serial;
	SendRssiC.AMPacket -> Serial;
	SendRssiC.AMSend -> SerialAMSenderC;

	App.RadioSend -> AMSenderC;
	App.RadioReceive -> AMReceiverC;
	App.RadioPacket -> Radio;
	App.RadioAMPacket -> Radio;

	App.CC2420Packet -> CC2420PacketC;
}
