//vim: filetype=nc:tabstop=4:expandtab:shiftwidth=0:softtabstop=-1

/**
**/

#include "Timer.h"
#include "TestSerial.h"

module TestSerialC {
  uses {
    interface SplitControl as Control;
    interface Leds;
    interface Boot;
    interface Receive;
    interface AMSend;
    interface Timer<TMilli> as MilliTimer;
    interface Packet;
  }
}
implementation {

  message_t packet;

  bool locked = FALSE;
  uint16_t counter = 0;
  
  event void Boot.booted() {
    call Control.start();
  }
  
  event void MilliTimer.fired() {
/*    counter++;
    if (locked) {
      return;
    }
    else {
      test_serial_msg_t* rcm = (test_serial_msg_t*)call Packet.getPayload(&packet, sizeof(test_serial_msg_t));
      if (rcm == NULL) {return;}
      if (call Packet.maxPayloadLength() < sizeof(test_serial_msg_t)) {
	return;
      }

      rcm->counter = counter;
      if (call AMSend.send(AM_BROADCAST_ADDR, &packet, sizeof(test_serial_msg_t)) == SUCCESS) {
	locked = TRUE;
      }
    }*/
  }

  event message_t* Receive.receive(message_t* bufPtr, void* payload, uint8_t len) {
	test_serial_msg_t *rcm, *pck;

    if (len != sizeof(test_serial_msg_t)) {return bufPtr;}
    else {
      rcm = (test_serial_msg_t*)payload;
      if (rcm->cmd & 0x5) {
		call Leds.led0Toggle();
      	pck = (test_serial_msg_t*)call Packet.getPayload(&packet, sizeof(test_serial_msg_t));
		pck->cmd = 0x6;
		pck->params[0] = 0x41;
		pck->params[1] = 0x42;
		pck->params[2] = 0x43;
		pck->length = 3;
		pck->moreData = 0;
      	if (call AMSend.send(AM_BROADCAST_ADDR, &packet, sizeof(test_serial_msg_t)) == SUCCESS) {call Leds.led1Toggle();}
      }
      return bufPtr;
    }
  }

  event void AMSend.sendDone(message_t* bufPtr, error_t error) {
    if (&packet == bufPtr) {
      locked = FALSE;
    }
  }

  event void Control.startDone(error_t err) {
    if (err == SUCCESS) {
      //call MilliTimer.startPeriodic(1000);
    }
  }
  event void Control.stopDone(error_t err) {}
}




