#include "LcdControl.h"
#include <string.h>

#define BUF_LEN 38

module LcdControlP
{
    provides {
        interface LcdControl;
        interface Msp430UartConfigure;
    }

    uses {
        interface Resource;
        interface UartStream;
        interface Leds;
        interface Alarm<TMilli, uint32_t>;
    }
}

implementation
{
	bool lcd_present = FALSE,
		first_send = TRUE,
		first_receive = TRUE,
		boot = TRUE,
		stop = TRUE;
	
	char disp_buf[BUF_LEN];
	char node_id[3];
	signed char stopcount = -1, bootcount=5;
    
	task void request(void)
    {
        call Resource.request();
    }

    task void release(void)
    {
        call Resource.release();
    }

    task void button1(void)
    {
        signal LcdControl.button1Pressed();
    }

    task void button2(void)
    {
        signal LcdControl.button2Pressed();
    }
    
    task void lcdFound(void)
    {
    	//call Leds.led1Toggle();
    	signal LcdControl.lcdEnabled();
    }

    /*****************************************************************************************
     * Uart Usage
     *****************************************************************************************/
	
	async event void Alarm.fired()
	{
		//call Leds.led0Toggle();
		
		if(lcd_present)
			boot = FALSE;
			
		if(bootcount==0 && !lcd_present) {
			boot = FALSE;
			call Resource.release();
			stopcount=0;
		}
		
		if(stopcount==0){
			call Leds.led2Toggle();
			stop = TRUE;
		} else if(stopcount > 0) {
			stopcount--;
		} else if(!lcd_present) {
			bootcount--;
		}
		if(boot) {
			post request();
			call Alarm.start(300);
		}else if(!stop) {
			post request();		
		}
	}
	
    /* Wenn wir den UART haben: */
    event void Resource.granted()
    {
    	/*Machen wir uns bereit zu empfangen und senden dann die gepufferten Daten*/
    	call UartStream.enableReceiveInterrupt();
    	call UartStream.send((uint8_t*) disp_buf, BUF_LEN);
    }

    async event void UartStream.sendDone(uint8_t *buf, uint16_t len, error_t error)
    {
    	//zuruecksetzen der Special Cmds
    	atomic disp_buf[34] = 0;
    	atomic disp_buf[35] = 0;
    	atomic disp_buf[36] = 0;
    	
    }

	//Wir haben was gesendet bekommen!
    async event void UartStream.receivedByte(uint8_t byte)
    {
    	//Jetzt erstmal "Ohren zu"
    	call UartStream.disableReceiveInterrupt();
        //Reagieren
        switch (byte) {
            case LCD_BUTTON1:
            	atomic lcd_present = TRUE;
                post button1();
            break;

            case LCD_BUTTON2:
            	atomic lcd_present = TRUE;
                post button2();
            break;
            
            case LCD_IDLE:
            	atomic lcd_present = TRUE;
            break;
            
            default:
            break;
        }
        //und den UART brauchen wir dann erstmal nichtmehr
        call Resource.release();
        
        //Das erste mal den LCD gefunden
        if(lcd_present && first_receive) {
        	post lcdFound();
        	atomic first_receive = FALSE;
        }
        
        if(!(call Alarm.isRunning()))
        	call Alarm.start(200);
    }

    async event void UartStream.receiveDone(uint8_t* buf, uint16_t len, error_t error)
    {
        //Hier koennte man laengere Nachrichten ueber den UART empfangen, fuer uns wohl eher uninteressant
    }
	
	/***************** Commands ********************/
	
	command void LcdControl.enable(void) {
		atomic {
			stop = FALSE;
			boot = TRUE;
			bootcount = 5;
			stopcount= -1;
			first_receive = TRUE;
			lcd_present = FALSE;
		}
		call LcdControl.puts("Initialising...", 1);
		itoa(TOS_NODE_ID, node_id, 10);
		call LcdControl.puts(node_id, 2);
		if(!(call Alarm.isRunning()))
			call Alarm.start(200);
	}
	
	command void LcdControl.disable(void) {
		atomic stopcount = 6;
	}
    
    command void LcdControl.puts(const char *s, uint8_t line_no)
    {
    	char *line1 = disp_buf+1;
    	char *line2 = disp_buf+18;
    	char *line;
    	uint8_t slen = 0;
    	uint8_t i;
    	
    	if(first_send) {
    		memset(disp_buf, 0, BUF_LEN);
    		atomic {
    			disp_buf[0] = LCD_CLEAR_LINE1;
    			disp_buf[17] = LCD_CLEAR_LINE2;
    			disp_buf[37] = LCD_BTRQ;
    		}
    		atomic first_send = FALSE;
        }
        
        switch(line_no) {
        	case 1:
        		line = line1;
        	break;
        	case 2:
        		line = line2;
        	break;
        	default:
        		memcpy(line1, line2, 16);
        		line = line2;
        	break;
        }
        
        slen = strlen(s);
        if (slen>16)
        	slen = 16;
        
        strncpy(line, s, slen);   
        for(i=slen; i<16; i++)
        	*(line+i) = 0;
    }
	
	command void LcdControl.beep(void)
	{
		atomic disp_buf[34] = LCD_BEEP;
	}
	
	command void LcdControl.led0Toggle(void)
	{
		atomic disp_buf[35] = LCD_LED1;
	}
	
	command void LcdControl.led1Toggle(void)
	{
		atomic disp_buf[36] = LCD_LED2;
	}
	

    /*****************************************************************************************
     * Uart Configuration, gesetzt auf 8N1-Modus bei 4800 Baud, entsprechend dem Display
     *****************************************************************************************/
    msp430_uart_union_config_t msp430_uart_4800_config =
    {
        {
            ubr:    UBR_1MHZ_4800,      // Baud rate (use enum msp430_uart_rate_t in msp430usart.h for predefined rates)
            umctl:  UMCTL_1MHZ_4800,    // Modulation (use enum msp430_uart_rate_t in msp430usart.h for predefined rates)
            ssel:   0x02,               // Clock source (00=UCLKI; 01=ACLK; 10=SMCLK; 11=SMCLK)
            pena:   0,                  // Parity enable (0=disabled; 1=enabled)
            pev:    0,                  // Parity select (0=odd; 1=even)
            spb:    0,                  // Stop bits (0=one stop bit; 1=two stop bits)
            clen:   1,                  // Character length (0=7-bit data; 1=8-bit data)
            listen: 0,                  // Listen enable (0=disabled; 1=enabled, feed tx back to receiver)
            mm:     0,                  // Multiprocessor mode (0=idle-line protocol; 1=address-bit protocol)
            ckpl:   0,                  // Clock polarity (0=normal; 1=inverted)
            urxse:  0,                  // Receive start-edge detection (0=disabled; 1=enabled)
            urxeie: 1,                  // Erroneous-character receive (0=rejected; 1=recieved and URXIFGx set)
            urxwie: 0,                  // Wake-up interrupt-enable (0=all characters set URXIFGx; 1=only address sets URXIFGx)
            utxe:   1,                  // 1:enable tx module
            urxe:   1                   // 1:enable rx module
        }
    };

    async command msp430_uart_union_config_t* Msp430UartConfigure.getConfig()
    {
        return &msp430_uart_4800_config;
    }
}
