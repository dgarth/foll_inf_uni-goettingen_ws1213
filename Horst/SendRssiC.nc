#include "SendRssi.h"

module SendRssiC
{
	provides
	{
		interface SendRssi;
		interface SplitControl;
	}
	uses
	{
		interface SplitControl as SendingChannelControl;
		interface Packet;
		interface AMSend;
		interface AMPacket;
	}
}

implementation
{
	bool busy = FALSE;
	message_t pkt;

	command error_t SendRssi.send(uint16_t source, uint16_t counter, uint16_t rssi)
	{
		RssiMsg *msg;

		if (busy)
			return FAIL;

		msg = call Packet.getPayload(&pkt, sizeof *msg);
		if (!msg)
			return FAIL;

		msg->source = source;
		msg->counter = counter;
		msg->rssi = rssi;

		return call AMSend.send(SENDRSSI_DEST, &pkt, sizeof *msg);
	}

	event void AMSend.sendDone(message_t *msg, error_t error)
	{
        if (msg == &pkt)
        {
            busy = FALSE;
        }
		signal SendRssi.sendDone(error);
	}

	/* the following commands/events just forward starting and stopping to the
	   wired SplitControl component. This ensures that SendRssiC is not used
	   without wiring a SplitControl component to it.
	 */

	command error_t SplitControl.start()
	{
		return call SendingChannelControl.start();
	}
	command error_t SplitControl.stop()
	{
		return call SendingChannelControl.stop();
	}
	event void SendingChannelControl.startDone(error_t error)
	{
		if (error == SUCCESS)
			signal SplitControl.startDone(error);
		else
			call SendingChannelControl.start();
	}
	event void SendingChannelControl.stopDone(error_t error)
	{
		if (error == SUCCESS)
			signal SplitControl.stopDone(error);
		else
			call SendingChannelControl.stop();
	}
}
