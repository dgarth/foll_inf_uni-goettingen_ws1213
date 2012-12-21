#include "Timer.h"
#include "CC2420.h"

#include "Horst.h"

module HorstC @safe()
{
    uses
	{
		interface Leds;
		interface Boot;
		interface Timer<TMilli> as Timer0;

		interface SplitControl as RadioControl;
		interface Packet as RadioPacket;
		interface AMPacket as RadioAMPacket;
		interface AMSend as RadioSend;
		interface Receive as RadioReceive;
		interface CC2420Packet;

		interface SendRssi;
		interface SplitControl as SendRssiControl;
	}
}

implementation
{
    bool radio_busy = FALSE;
    message_t radio_pkt;
	uint16_t count = 0;

    event void Boot.booted(void)
    {
		call Leds.led0On();
		call Leds.led1On();
        call SendRssiControl.start();
        call RadioControl.start();
    } 

	event void Timer0.fired(void)
	{
		RadioMsg *outmsg;
		if (radio_busy)
			return;

		outmsg = call RadioPacket.getPayload(&radio_pkt, sizeof(RadioMsg));
		if (!outmsg)
			return;

		outmsg->count = count++;
		outmsg->nodeid = TOS_NODE_ID;

		if (call RadioSend.send(AM_BROADCAST_ADDR, &radio_pkt, sizeof(RadioMsg)) != SUCCESS)
			return;

		call Leds.led0On();
		radio_busy = TRUE;
	}

    event void SendRssi.sendDone(error_t error)
    {
		call Leds.led1Off();
    }

    event void RadioSend.sendDone(message_t *msg, error_t error)
    {
        if (&radio_pkt == msg)
        {
            call Leds.led0Off();
            radio_busy = FALSE;
        }
    }

    event message_t *RadioReceive.receive(message_t *msg, void *payload, uint8_t len)
    {
		uint16_t rssi;
		RadioMsg *inmsg;

		call Leds.led2Toggle();

        if (len != sizeof(RadioMsg))
			return msg;

		rssi = call CC2420Packet.getRssi(msg);

		inmsg = call RadioPacket.getPayload(msg, sizeof(RadioMsg));
		if (!inmsg)
			return msg;

		if (call SendRssi.send(inmsg->nodeid, inmsg->count, rssi) == SUCCESS)
			call Leds.led1On();

        return msg;
    }


    event void SendRssiControl.startDone(error_t err)
    {
        if (err == SUCCESS)
            call Leds.led0Off();
        else
            call SendRssiControl.start();
    }

    event void SendRssiControl.stopDone(error_t err)
    {
    }

    event void RadioControl.startDone(error_t err)
    {
        if (err == SUCCESS)
        {
            call Leds.led1Off();
			call Timer0.startPeriodic(TIMER_PERIOD);
        }
        else
        {
            call RadioControl.start();
        }
    }

    event void RadioControl.stopDone(error_t err)
    {
    }
}
