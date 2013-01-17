#include "allnodes.h"

configuration MeasureC
{
    provides interface Measure;
}

implementation
{
    components MeasureP as M;

    /* export the Measure interface */
    Measure = M;

    /* for starting up the radio */
    components ActiveMessageC;
    M.RadioControl -> ActiveMessageC;

    /* to send/receive packets */
    components new AMSenderC(AM_MEASURE);
    components new AMReceiverC(AM_MEASURE);
    M.Send -> AMSenderC;
    M.Receive -> AMReceiverC;

    /* for sending "dummy" packets to the partner mote in intervals */
    components new TimerMilliC() as Timer;
    M.Timer -> Timer;

    /* for getting the sender of received dummy packet */
    M.AMPacket -> ActiveMessageC;

    /* for getting RSSI value */
    components CC2420PacketC;
    M.RssiPacket -> CC2420PacketC;
}
