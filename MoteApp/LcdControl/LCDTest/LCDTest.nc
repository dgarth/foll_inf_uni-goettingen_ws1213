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
    bool ready = FALSE;
    char *str[] = {"foo", "bar"};
    
    event void Boot.booted(void)
    {
        call Timer.startPeriodic(4000);
        call LcdControl.puts("Good Morning!", 2);
    }

    event void LcdControl.button1Pressed(void)
    {
        call LcdControl.led0Toggle();
    }

    event void LcdControl.button2Pressed(void)
    {
    	call Leds.led0Toggle();
    	call LcdControl.beep();
        call LcdControl.led1Toggle();
    }

    event void Timer.fired(void)
    {
       state ^= 1;
       call LcdControl.checkReady();
        //call LcdControl.buttonRequest();
    }
    
    event void LcdControl.lcdReady(void) 
    {
    	call LcdControl.puts(str[state], 1);
    }
}
