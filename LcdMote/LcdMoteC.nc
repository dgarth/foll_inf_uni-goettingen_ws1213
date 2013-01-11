#include <string.h>

module LcdMoteC
{
    uses {
        interface Boot;
        interface Leds;
        interface Timer<TMilli>;
        interface LcdDisp;
    }
}

implementation
{
    int state = 0;

    event void Boot.booted(void)
    {
        call Timer.startPeriodic(2000);
        call LcdDisp.print("Good Morning", "I booted!");
    }

    event void LcdDisp.button1Pressed(void)
    {
        call Leds.led0Toggle();
    }

    event void LcdDisp.button2Pressed(void)
    {
        call Leds.led1Toggle();
    }

    event void Timer.fired(void)
    {
        if ((state ^= 1)) {
            call LcdDisp.print("asdf", "wtf");
        }
        else {
            call LcdDisp.print("foo", "axfgsrhg");
        }
    }
}
