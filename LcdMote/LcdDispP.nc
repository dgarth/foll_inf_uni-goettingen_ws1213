#include "stdlib.h"
#include "string.h"

module LcdDispP {	
	provides {
        interface LcdDisp;
		interface Msp430UartConfigure;
	} uses {
        interface Boot;
		interface Timer<TMilli>;
		interface Resource;
		interface UartStream;
	}
}

implementation {
	
    #define LEN 16

    bool 
        requested=FALSE,
        printing=FALSE;

    uint8_t
        lines[2 * (LEN + 1)],
        *line1 = lines + 1,
        *line2 = lines + 1 + LEN;


    event void Boot.booted(void)
    {
        call Timer.startPeriodic(200);
        call Resource.request();
    }

	/*****************************************************************************************
	 * Uart Usage
	 *****************************************************************************************/

	/* Wenn wir den UART haben: */
	event void Resource.granted() {
        if (printing) {
            printing = FALSE;
            call UartStream.send(lines, sizeof lines); //unseren vorher aufbereiteten String senden
        }
        else {
            uint8_t nop[] = { 0x16 };
            call UartStream.send(nop, sizeof nop);
        }
	}
	
	async event void UartStream.sendDone(uint8_t *buf, uint16_t len, error_t error) {
	}
	
    /* klappt nicht ?! */
	async event void UartStream.receivedByte(uint8_t byte) {
        if (byte == 0x11) {
            signal LcdDisp.button1Pressed();
        }
        if (byte == 0x12) {
            signal LcdDisp.button2Pressed();
        }
        signal LcdDisp.button2Pressed();

        requested = FALSE;
        call Resource.release();
	}
	
	async event void UartStream.receiveDone(uint8_t* buf, uint16_t len, error_t error) {
		//Hier koennte man laengere Nachrichten ueber den UART empfangen, fuer uns wohl eher uninteressant
	}

    command void LcdDisp.print(const char *s1, const char *s2)
    {
        memset(line1, ' ', LEN);
        memset(line2, ' ', LEN);

        line1[-1] = 0x13;
        line2[-1] = 0x14;

        if (*s1)
            memcpy(line1, s1, strlen(s1));
        if (*s2)
            memcpy(line2, s2, strlen(s2));

        printing = TRUE;
		call Resource.request();
    }
	
	/***************** Timer Events ****************/
	event void Timer.fired() {
        if (!requested) {
            requested = TRUE;
            call Resource.request();
        }
	}

	/*****************************************************************************************
 	* Uart Configuration, gesetzt auf 8N1-Modus bei 4800 Baud, entsprechend dem Display
 	*****************************************************************************************/
	msp430_uart_union_config_t msp430_uart_4800_config = {
		{
			utxe	 : 1, 
			urxe	 : 1, 
			ubr		 : UBR_1MHZ_4800,			// Baud rate (use enum msp430_uart_rate_t in msp430usart.h for predefined rates)
			umctl	 : UMCTL_1MHZ_4800,		// Modulation (use enum msp430_uart_rate_t in msp430usart.h for predefined rates)
			ssel	 : 0x02,							// Clock source (00=UCLKI; 01=ACLK; 10=SMCLK; 11=SMCLK)
			pena	 : 0,									// Parity enable (0=disabled; 1=enabled)
			pev		 : 0,									// Parity select (0=odd; 1=even)
			spb		 : 0,									// Stop bits (0=one stop bit; 1=two stop bits)
			clen	 : 1,									// Character length (0=7-bit data; 1=8-bit data)
			listen : 0,									// Listen enable (0=disabled; 1=enabled, feed tx back to receiver)
			mm		 : 0,									// Multiprocessor mode (0=idle-line protocol; 1=address-bit protocol)
			ckpl	 : 0,									// Clock polarity (0=normal; 1=inverted)
			urxse	 : 0,									// Receive start-edge detection (0=disabled; 1=enabled)
			urxeie : 1,									// Erroneous-character receive (0=rejected; 1=recieved and URXIFGx set)
			urxwie : 0,									// Wake-up interrupt-enable (0=all characters set URXIFGx; 1=only address sets URXIFGx)
			utxe	 : 1,									// 1:enable tx module
			urxe	 : 1									// 1:enable rx module
		}
	};
		
	async command msp430_uart_union_config_t* Msp430UartConfigure.getConfig() {
		return &msp430_uart_4800_config;
	}
}
