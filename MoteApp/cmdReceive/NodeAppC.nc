#include "ProjectRssi.h"
#include "/opt/tinyos-2.1.2/tos/lib/printf/printf.h"
#define NEW_PRINTF_SEMANTICS
configuration ProjectRssiAppC
{
}
implementation
{
    components MainC, ProjectRssiC, LedsC;
    components new TimerMilliC() as Timer0;
    components PrintfC;
    components SerialStartC;
    components CC2420PacketC;

    components ActiveMessageC;
    components new AMSenderC(6);
    components new AMReceiverC(6);

    ProjectRssiC -> MainC.Boot;

    ProjectRssiC.Timer0 -> Timer0;

    ProjectRssiC.CC2420Packet->CC2420PacketC;
    ProjectRssiC.Leds -> LedsC;

    ProjectRssiC.Packet -> AMSenderC;
    ProjectRssiC.AMPacket -> AMSenderC;
    ProjectRssiC.AMSend -> AMSenderC;
    ProjectRssiC.AMControl -> ActiveMessageC;

}

