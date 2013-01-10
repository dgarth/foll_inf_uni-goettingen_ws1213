//

/**
**/

#include "ConsoleMsg.h"

configuration MoteConsoleAppC {}
implementation {
  components MoteConsoleC as App, LedsC, MainC;
  components SerialActiveMessageC as AM;

  App.Boot -> MainC.Boot;
  App.Control -> AM;
  App.Receive -> AM.Receive[AM_CONSOLE_MSG];
  App.AMSend -> AM.AMSend[AM_CONSOLE_MSG];
  App.Leds -> LedsC;
  App.Packet -> AM;
}


