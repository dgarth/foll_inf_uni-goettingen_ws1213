#include "LcdControl.h"
#include <string.h>

module LcdControlP
{
    provides {
        interface LcdControl;
        interface Msp430UartConfigure;
    }

    uses {
        interface Boot;
        interface Timer<TMilli>;
        interface Resource;
        interface UartStream;
    }
}

implementation
{
    bool
        requested=FALSE,
        printing=FALSE;

    uint8_t
        lines[2 * (LCD_LEN + 1)],
        *line1 = lines + 1,
        *line2 = lines + 1 + LCD_LEN;


    task void request(void)
    {
        requested = TRUE;
        call Resource.request();
    }

    task void release(void)
    {
        requested = FALSE;
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

    event void Boot.booted(void)
    {
        call Timer.startPeriodic(200);
        call Resource.request();
    }

    /*****************************************************************************************
     * Uart Usage
     *****************************************************************************************/

    /* Wenn wir den UART haben: */
    event void Resource.granted()
    {
        bool p;
        atomic {
            p = printing;
        }
        if (p) {
            call UartStream.send(lines, sizeof lines); //unseren vorher aufbereiteten String senden
        }
        else {
            uint8_t nop[] = { LCD_NOP };
            call UartStream.enableReceiveInterrupt(); //<= das hier war das Hauptproblem
            call UartStream.send(nop, sizeof nop);
        }
    }

    /* Wenn wir fertig geschrieben haben, geben wir den UART frei, bei Taster-Abfrage
     * erst, wenn wir empfangen haben.
     */
    async event void UartStream.sendDone(uint8_t *buf, uint16_t len, error_t error)
    {
        atomic {
            if(printing) {
                printing = FALSE;
                post release();
            }
        }
    }

    /* klappt jetzt! */
    async event void UartStream.receivedByte(uint8_t byte)
    {
        switch (byte) {

            case LCD_BUTTON1:
                post button1();
                break;

            case LCD_BUTTON2:
                post button2();
                break;
        }

        //Nach empfang, UART freigeben
        call UartStream.disableReceiveInterrupt();
        post release();
    }

    async event void UartStream.receiveDone(uint8_t* buf, uint16_t len, error_t error)
    {
        //Hier koennte man laengere Nachrichten ueber den UART empfangen, fuer uns wohl eher uninteressant
    }


    /***************** Timer Events ****************/
    event void Timer.fired()
    {
        if (!requested) {
            post request();
        }
    }


    command void LcdControl.puts(const char *s)
    {
        static bool first_time = TRUE;
        size_t len = strlen(s);
        uint8_t *line;

        if (first_time) {
            /* prepare buffer */
            line1[-1] = LCD_CLEAR_LINE1;
            line2[-1] = LCD_CLEAR_LINE2;
            memset(line1, ' ', LCD_LEN);
            memset(line2, ' ', LCD_LEN);

            line = line1;
            first_time = FALSE;
        }
        else {
            /* clear first line */
            memset(line1, ' ', LCD_LEN);

            /* move second line up */
            memcpy(line1, line2, LCD_LEN);

            line = line2;
        }

        /* clear output line */
        memset(line, ' ', LCD_LEN);

        if (len > LCD_LEN)
            len = LCD_LEN;

        memcpy(line, s, len);

        atomic {
            printing = TRUE;
            post request();
        }
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
