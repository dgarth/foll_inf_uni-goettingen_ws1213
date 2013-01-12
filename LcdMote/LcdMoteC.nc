#include <string.h>

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
        call LcdControl.print("Good Morning", "I booted!");
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
            call LcdControl.print("asdf", "wtf");
        }
        else {
            call LcdControl.print("foo", "axfgsrhg");
        }
    }
}
