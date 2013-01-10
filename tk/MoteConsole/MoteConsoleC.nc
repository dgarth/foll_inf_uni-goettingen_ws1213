//

/**
**/

#include "Timer.h"
#include "ConsoleMsg.h"

module MoteConsoleC {
  uses {
    interface SplitControl as Control;
    interface Leds;
    interface Boot;
    interface Receive;
    interface AMSend;
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
  
  event message_t* Receive.receive(message_t* bufPtr, void* payload, uint8_t len) {
	console_msg_t *cm;
	uint8_t led;
	uint8_t state;

    if (len != sizeof(console_msg_t)) {return bufPtr;}

	cm = (console_msg_t*) payload;

	/*if (cm->cmd == 5) {
		call Leds.led0On();
	}

	if (cm->data[0] == 1) {
		call Leds.led1On();
	}*/

	switch (cm->cmd) {
		case 5:
			state = call Leds.get();
			led = cm->data[0];
			if (state & led) {
				call Leds.set(state & ~led);
			} else {
				call Leds.set(state | led);
			}
			break;
	}

	return bufPtr;

      	//if (call AMSend.send(AM_BROADCAST_ADDR, &packet, sizeof(test_serial_msg_t)) == SUCCESS) {call Leds.led1Toggle();}
  }

  event void AMSend.sendDone(message_t* bufPtr, error_t error) {
    if (&packet == bufPtr) {
      locked = FALSE;
    }
  }

  event void Control.startDone(error_t err) {}
  event void Control.stopDone(error_t err) {}
}




