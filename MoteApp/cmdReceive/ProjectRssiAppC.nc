// vim: filetype=nc:tabstop=4:expandtab:shiftwidth=0:softtabstop=-1
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
    //components new AMSenderC(6);
    //components new AMReceiverC(6);

    ProjectRssiC -> MainC.Boot;

    ProjectRssiC.Timer0 -> Timer0;

    ProjectRssiC.CC2420Packet->CC2420PacketC;
    ProjectRssiC.Leds -> LedsC;

    //ProjectRssiC.AMSend -> AMSenderC;
    ProjectRssiC.AMControl -> ActiveMessageC;

    //ProjectRssiC.Receive -> AMReceiverC;
    
    components MeasureC;
    ProjectRssiC.Measure -> MeasureC;
    
    components NodeToolsC;
    ProjectRssiC.NodeTools -> NodeToolsC;

    components DisseminationC;
    ProjectRssiC.DisControl -> DisseminationC;

    /* DisseminatorC(hier kommt der datentyp rein, und hier ein 
    * beliebiger key) 
    * Haben ja nur ein node_msg_t ding, deshalb key egal
    */
    components new DisseminatorC(node_msg_t,0x1234) as DisMsg;
    ProjectRssiC.DisMsg -> DisMsg;
    ProjectRssiC.DisUpdate -> DisMsg;
    
    /* Collection kram
    *
    */
    components CollectionC as Collector;
    components new CollectionSenderC(0xee);
    ProjectRssiC.AMPacket -> ActiveMessageC;
    ProjectRssiC.RoutingControl -> Collector;
    ProjectRssiC.ColSend -> CollectionSenderC;
    ProjectRssiC.RootControl -> Collector;
    ProjectRssiC.ColReceive -> Collector.Receive[0xee];
}

