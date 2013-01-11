#include <avr/io.h>
#include <util/delay.h>
#include <avr/interrupt.h>
#include "lcd.h"
#include "uart.h"


#define BT1 0x02
#define BT2 0x01
#define GREEN 0x02
#define RED 0x01
#ifndef F_CPU
	#define F_CPU 1000000UL	//Der AVR ist mit 1MHz getaktet
#endif
#define UART_BAUD_RATE      4800

/* Aus-/Eingänge, LCD-Controllerchip und UART initialisieren */
void init_all(void) {
	DDRC |= _BV(PC5) | _BV(PC4) | _BV(PC3);
	DDRD |= _BV(PD4);
	DDRD &= ~_BV(PD2) & ~_BV(PD3);
	PORTD |= _BV(PD4);
	
	PORTC &= ~_BV(PC3);
	PORTC |= _BV(PC4) | _BV(PC5);
	
	PORTC |= _BV(PC3); //BEEP!
	_delay_ms(100);
	lcd_init();
	
	/*UART-Einstellen, nach Atmel Datenblatt*/
	uart_init( UART_BAUD_SELECT(UART_BAUD_RATE,F_CPU) );
	
	GICR |= (1<<INT0) | (1<<INT1);
	MCUCR |=(0<<ISC01) | (0<<ISC00) | (0<<ISC11) | (0<<ISC10);
	
	sei();
	PORTC &= ~_BV(PC3);	//Beep-Ende
}

/* Den FlipFlop, an dem die Taster haengen, resetten */
void clear_buttons(void) {
	PORTD &= ~_BV(PD4);
	PORTD |= _BV(PD4);
}

/* LED-Status setzen. Bsp.: setLeds(GREEN | RED); => Beide LEDs an */
void setLeds(uint8_t mask) {
	mask = (~(mask<<4)) & (_BV(PC5) | _BV(PC4));
	PORTC = (PORTC & ~_BV(PC5) & ~_BV(PC4)) | mask;
}

/* LED-Status abfragen, mask entsprechen setLeds */
uint8_t getLeds(void) {
	return (~PORTC & (_BV(PC5) | _BV(PC4)))>>4;
}

/* Eine Viertelsekunde Piepen */
void beep(void) {
	PORTC |= _BV(PC3); //BEEP!
	_delay_ms(250);
	PORTC &= ~_BV(PC3);
}
	

/* Interrupt-Routine fuer Button 2 */
ISR (INT0_vect) {
    uart_putc(0x12); //DC2 senden
  	_delay_ms(300);
    clear_buttons();
    
} 

/* Interrupt-Routine fuer Button 1 */
ISR (INT1_vect) {
    uart_putc(0x11); //DC1 senden 
	_delay_ms(300);
    clear_buttons();
} 

int main(void) {
	unsigned int b;
	unsigned char c;
	
	init_all();
	lcd_puts("Ready.", FIRST);
	for(;;)
    {
        /*
         * Get received character from ringbuffer
         * uart_getc() returns in the lower byte the received character and 
         * in the higher byte (bitmask) the last receive error
         * UART_NO_DATA is returned when no data is available.
         *
         */
        b = uart_getc();
        if ( b & UART_NO_DATA )
        {
            /* 
             * no data available from UART 
             */
        }
        else
        {
            /*
             * new data available from UART
             * check for Frame or Overrun error
             */
            if ( b & UART_FRAME_ERROR )
            {
                /* Framing Error detected, i.e no stop bit detected */
                lcd_puts("UART Frame Error", FIRST);
            }
            if ( b & UART_OVERRUN_ERROR )
            {
                /* 
                 * Overrun, a character already present in the UART UDR register was 
                 * not read by the interrupt handler before the next character arrived,
                 * one or more received characters have been dropped
                 */
                lcd_puts("UART Overrun Error", FIRST);
            }
            if ( b & UART_BUFFER_OVERFLOW )
            {
                /* 
                 * We are not reading the receive buffer fast enough,
                 * one or more received character have been dropped 
                 */
                lcd_puts("Buffer overflow error", FIRST);
            }
            /* 
             * send received character back
             */
            c = (unsigned char) b;
            switch(c) {
            	case 0x07: //BELL
            		beep(); //BEEP!!!
            	break;
            	
            	case 0x11: //DEVICE CONTROL 1
            		setLeds(getLeds() ^ RED); //rote LED togglen
            	break;
            	
            	case 0x12: //DEVICE CONTROL 2
            		setLeds(getLeds() ^ GREEN); //gruene LED togglen
            	break;
            	
            	case 0x13: //DEVICE CONTROL 3
            		lcd_clearLine(FIRST); //Erste Zeile leeren und ab da schreiben
            	break;
            	
            	case 0x14: //DEVICE CONTROL 4
            		lcd_clearLine(SECOND); //Zweite Zeile leeren und ab da schreiben
            	break;
            	
            	default:	// Normales Zeichen
            		lcd_putc(c); //Zeichen schreiben
            	break;
            }
        }
    }
	
	return 0;
}