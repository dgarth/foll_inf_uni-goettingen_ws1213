//vim: filetype=nc:tabstop=4:expandtab:shiftwidth=0:softtabstop=-1
#include "CC2420.h"

#include "ProjectRssi.h"
#include "../allnodes.h"

module ProjectRssiC @safe()
{
    uses interface Leds;
    uses interface Boot;

    uses interface Timer<TMilli> as Timer0;
    uses interface CC2420Packet;

    uses interface Packet;
    uses interface AMPacket;
    uses interface AMSend;
    uses interface SplitControl as AMControl;
    uses interface Receive;

    
}

implementation
{
    bool busy = FALSE;
    message_t pkt;

    event void Boot.booted()
    {
        call Leds.led0On();
        call Leds.led1On();
        call AMControl.start();
        call Timer0.startPeriodic(500);
    } 

    event void AMControl.startDone(error_t err)
    {
        if (err == SUCCESS)
        {
            call Leds.led0Off();
            call Timer0.startPeriodic(TIMER_PERIOD_MILLI);
        }
        else
        {
            call AMControl.start();
        }
    }
    event void AMControl.stopDone(error_t err)
    {
    }

    event void Timer0.fired()
    {

        if (!busy)
        {
            ProjectRssiMsg *msg = call Packet.getPayload(&pkt, sizeof (ProjectRssiMsg));
            pkt->nodeid = 12; // msg nach pkt 
            if (call AMSend.send(AM_BROADCAST_ADDR, &pkt, sizeof(ProjectRssiMsg)) == SUCCESS)
            {
                printf("Sende Packet\n");
                printfflush();
                busy = TRUE;
            }
        }
    }

    event void AMSend.sendDone(message_t *msg, error_t error)
    {
        if (&pkt == msg)
        {
            busy = FALSE;
        }
    }

    event message_t *Receive.receive(message_t *msg, void *payload, uint8_t len)
    {
        int8_t r = call CC2420Packet.getRssi(msg);

        printf("bla %d\n",r);
        printfflush();

        return msg;
    }
}

