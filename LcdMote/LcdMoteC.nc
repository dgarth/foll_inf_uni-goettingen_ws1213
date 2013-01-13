#include "LcdControl.h"

module LcdMoteC
{
    uses {
        interface Boot;
        interface Leds;
        interface Timer<TMilli>;
        interface LcdControl;
    }
}

implementation
{
    int state = 0;

    event void Boot.booted(void)
    {
        call Timer.startPeriodic(2000);
        call LcdControl.puts("Good Morning!");
        call LcdControl.lcdprintf("Node %u booted", TOS_NODE_ID);
    }

    event void LcdControl.button1Pressed(void)
    {
        call Leds.led0Toggle();
    }

    event void LcdControl.button2Pressed(void)
    {
        call Leds.led1Toggle();
    }

    event void Timer.fired(void)
    {
        if ((state ^= 1)) {
            call LcdControl.puts("foo");
        }
        else {
            call LcdControl.puts("bar");
        }
    }
}
