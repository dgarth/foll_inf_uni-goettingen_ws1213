#include "../Rssi.h"
#include <AM.h>

#define GETRSSI(msg) call RssiPacket.getRssi(msg)

module MoteC
{
    uses
	{
		interface Boot;
		interface Leds;

		interface SplitControl as RadioControl;

		interface Timer<TMilli> as BeaconTimer;
		interface AMSend as BeaconSend;
		interface Receive as BeaconReceive;

		interface CC2420Packet as RssiPacket;

		interface Send as CollectionSend;
	}
}

implementation
{
    bool
		beacon_busy = FALSE,
		collect_busy = FALSE;

    message_t
		beacon_pkt,
		collect_pkt;

	uint16_t counter;

    event void Boot.booted(void)
    {
        call RadioControl.start();
    } 

    event void RadioControl.startDone(error_t err)
    {
        if (err == SUCCESS) {
			call BeaconTimer.startPeriodic(BEACON_PERIOD);
        }
        else {
            call RadioControl.start();
        }
    }

    event void RadioControl.stopDone(error_t err)
    {
    }

    event message_t *BeaconReceive.receive(message_t *msg, void *payload, uint8_t len)
    {
		BeaconMsg *inmsg = payload;
		RssiMsg *outmsg;

		led_toggle(LED_RCV);

        if (collect_busy || len != sizeof *inmsg) {
			return msg;
		}

		outmsg = call CollectionSend.getPayload(&collect_pkt, sizeof *outmsg);
		if (!outmsg) {
			return msg;
		}

		outmsg->source = inmsg->nodeid;
		outmsg->destination = TOS_NODE_ID;
		outmsg->counter = inmsg->counter;
		outmsg->rssi = GETRSSI(msg);

		if (call CollectionSend.send(&collect_pkt, sizeof *outmsg) == SUCCESS) {
			led_on(LED_COLLECT);
			collect_busy = TRUE;
		}

        return msg;
    }
	
	event void CollectionSend.sendDone(message_t *msg, error_t error)
	{
		led_off(LED_COLLECT);
		collect_busy = FALSE;
	}

	event void BeaconTimer.fired(void)
	{
		BeaconMsg *outmsg;

		outmsg = call BeaconSend.getPayload(&beacon_pkt, sizeof *outmsg);
		if (!outmsg || beacon_busy) {
			return;
		}

		outmsg->counter = counter++;
		outmsg->nodeid = TOS_NODE_ID;

		if (call BeaconSend.send(AM_BROADCAST_ADDR, &beacon_pkt, sizeof *outmsg) == SUCCESS) {
			led_on(LED_BEACON);
			beacon_busy = TRUE;
		}
	}

	event void BeaconSend.sendDone(message_t *msg, error_t error)
	{
		if (msg == &beacon_pkt) {
			led_off(LED_BEACON);
			beacon_busy = FALSE;
		}
	}
}