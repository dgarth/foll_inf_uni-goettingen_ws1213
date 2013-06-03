#include <avr/io.h>
#include <util/delay.h>
#include <avr/interrupt.h>
#include "uart.h"
#include "i2cmaster.h"

#ifndef F_CPU
	#define F_CPU 4000000UL	//Der AVR ist mit 4MHz getaktet
#endif
#define UART_BAUD_RATE      4800

int main(void) {
	unsigned int b;
	unsigned char c;
	
	i2c_init();
	i2c_start_wait(0x70+I2C_WRITE);
	i2c_write(0x00);
	i2c_write(0x4a);
	i2c_stop();
	
	_delay_ms(250);
	
	i2c_start_wait(0x70+I2C_WRITE);
	i2c_write(0x00);
	i2c_write(0x46);
	i2c_stop();
	
	uart_init( UART_BAUD_SELECT(UART_BAUD_RATE,F_CPU) );
    sei();
    
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
                //lcd_puts("UART Frame Error", FIRST);
            }
            if ( b & UART_OVERRUN_ERROR )
            {
                /* 
                 * Overrun, a character already present in the UART UDR register was 
                 * not read by the interrupt handler before the next character arrived,
                 * one or more received characters have been dropped
                 */
                //lcd_puts("UART Overrun Error", FIRST);
            }
            if ( b & UART_BUFFER_OVERFLOW )
            {
                /* 
                 * We are not reading the receive buffer fast enough,
                 * one or more received character have been dropped 
                 */
                //lcd_puts("Buffer overflow error", FIRST);
            }
            
            c = (unsigned char) b;
            i2c_start_wait(0x70+I2C_WRITE);
			i2c_write(0x01);
			i2c_write(c);
			i2c_write(c);
			i2c_stop();
            
        }
    }
	
	return 0;
}