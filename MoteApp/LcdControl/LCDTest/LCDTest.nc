// vim: filetype=nc:tabstop=4:expandtab:shiftwidth=0:softtabstop=-1

#include "LcdControl.h"

module LcdTest
{
    uses {
        interface Boot;
        interface Leds;
        interface LcdControl;
    }
}

implementation
{
    
    event void Boot.booted(void)
    {
        call LcdControl.enable();
    }

    event void LcdControl.button1Pressed(void)
    {
        call LcdControl.puts("Button 1", 2);
        call LcdControl.led0Toggle();
    }

    event void LcdControl.button2Pressed(void)
    {
		call LcdControl.puts("Button 2", 2);
		call LcdControl.led1Toggle();
    }

    
    event void LcdControl.lcdEnabled(void) 
    {
    	call LcdControl.puts("LCD Found!", 1);
    }
}
