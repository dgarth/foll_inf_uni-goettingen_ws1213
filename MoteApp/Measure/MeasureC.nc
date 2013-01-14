#include "../allmotes.h"

configuration MeasureC
{
    provides interface Measure;
}

implementation
{
    components MeasureP as M;
    Measure = M;

    components new TimerMilliC() as Timer;
    M.Timer -> Timer;

    components ActiveMessageC;
    M.RadioControl -> ActiveMessageC;
    M.AMPacket -> ActiveMessageC;

    components new AMSenderC(AM_MEASURE);
    components new AMReceiverC(AM_MEASURE);
    M.Send -> AMSenderC;
    M.Receive -> AMReceiverC;

    components CC2420PacketC;
    M.RssiPacket -> CC2420PacketC;
}
