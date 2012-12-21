#include <AM.h>

interface SendRssi
{
	command error_t send(uint16_t from, uint16_t counter, uint16_t rssi);
	event void sendDone(error_t error);
}
