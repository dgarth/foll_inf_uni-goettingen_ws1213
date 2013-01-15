#include "LcdControl.h"

module LcdTest
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
        call LcdControl.puts("Good Morning!", 2);
        call LcdControl.lcdprintf("Node %u booted", TOS_NODE_ID);
    }

    event void LcdControl.button1Pressed(void)
    {
        call LcdControl.led0Toggle();
    }

    event void LcdControl.button2Pressed(void)
    {
    	call LcdControl.beep();
        call LcdControl.led1Toggle();
    }

    event void Timer.fired(void)
    {
        if ((state ^= 1)) {
            call LcdControl.puts("foo", 1);
        }
        else {
            call LcdControl.puts("bar", 1);
        }
    }
}
