#include "Horst.h"

configuration HorstAppC
{
}
implementation
{
	components HorstC as App;

    components MainC, LedsC;
	components new TimerMilliC() as Timer0;
    App.Boot	-> MainC.Boot;
    App.Leds	-> LedsC;
	App.Timer0	-> Timer0;

	components ActiveMessageC as Radio;
    components new AMSenderC(AM_RADIOMSG);
    components new AMReceiverC(AM_RADIOMSG);
	components CC2420PacketC;
	App.RadioControl 	-> Radio;
	App.RadioPacket 	-> Radio;
	App.RadioAMPacket 	-> Radio;
	App.RadioSend 		-> AMSenderC;
	App.RadioReceive 	-> AMReceiverC;
	App.CC2420Packet 	-> CC2420PacketC;

	components SendRssiC;
	App.SendRssi 		-> SendRssiC;
	App.SendRssiControl -> SendRssiC;

	/* wire SendRssi so that it sends to the serial console */
    components SerialActiveMessageC as RssiAM;
    components new SerialAMSenderC(AM_RSSIMSG) as RssiAMSender;
	SendRssiC.SendingChannelControl -> RssiAM;
	SendRssiC.Packet 				-> RssiAM;
	SendRssiC.AMPacket 				-> RssiAM;
	SendRssiC.AMSend				-> RssiAMSender;
}
