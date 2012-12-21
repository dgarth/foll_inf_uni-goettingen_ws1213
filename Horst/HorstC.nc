#include "Timer.h"
#include "CC2420.h"

#include "Horst.h"

module HorstC @safe()
{
    uses interface Leds;
    uses interface Boot;

	uses interface Timer<TMilli> as Timer0;

    uses interface SplitControl as RadioControl;
    uses interface SplitControl as SerialControl;

    uses interface Packet as SerialPacket;
    uses interface Packet as RadioPacket;

    uses interface AMPacket as SerialAMPacket;
    uses interface AMPacket as RadioAMPacket;

    uses interface AMSend as SerialSend;
    uses interface AMSend as RadioSend;

    uses interface Receive as RadioReceive;
    uses interface CC2420Packet;
}

implementation
{
    bool serial_busy = FALSE, radio_busy = FALSE;

    message_t serial_pkt, radio_pkt;

	uint16_t count = 0;

    event void Boot.booted(void)
    {
		call Leds.led0On();
		call Leds.led1On();
        call SerialControl.start();
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

    event void SerialSend.sendDone(message_t *msg, error_t error)
    {
        if (&serial_pkt == msg)
        {
            call Leds.led1Off();
            serial_busy = FALSE;
        }
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
		SerialMsg *outmsg;

		call Leds.led2Toggle();

        if (len != sizeof(RadioMsg))
			return msg;

		rssi = call CC2420Packet.getRssi(msg);

		if (serial_busy)
			return msg;

		outmsg = call SerialPacket.getPayload(&serial_pkt, sizeof (SerialMsg));
		inmsg = call RadioPacket.getPayload(msg, sizeof(RadioMsg));
		if (!outmsg)
			return msg;

		outmsg->nodeid = inmsg->nodeid;
		outmsg->count = inmsg->count;
		outmsg->rssi = rssi;

		if (call SerialSend.send(AM_BROADCAST_ADDR, &serial_pkt, sizeof(SerialMsg)) != SUCCESS)
			return msg;

		call Leds.led1On();
		serial_busy = TRUE;
        return msg;
    }


    event void SerialControl.startDone(error_t err)
    {
        if (err == SUCCESS)
            call Leds.led0Off();
        else
            call SerialControl.start();
    }

    event void SerialControl.stopDone(error_t err)
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
