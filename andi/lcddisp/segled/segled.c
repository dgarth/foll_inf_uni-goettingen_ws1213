#include <avr/io.h>
#include <util/delay.h>
#include <avr/interrupt.h>
#include <stdlib.h>
#include "uart.h"
#include "i2cmaster.h"

#ifndef F_CPU
	#define F_CPU 4000000UL	//Der AVR ist mit 4MHz getaktet
#endif
#define UART_BAUD_RATE      4800

int cmpfunc (const void * a, const void * b)
{
  return ( *(unsigned char*)a - *(unsigned char*)b );
}

void led_write(unsigned char a) {
  
  unsigned char led_byte[2], b = 0, i = 0;
  
  while(i<2) {
	b = a % 10;
	a /= 10;
	switch(b){
	  case 0:
		led_byte[i] = 0x3f;
	  break;
	  case 1:
		led_byte[i] = 0x06;
	  break;
	  case 2:
		led_byte[i] = 0x5b;
	  break;
	  case 3:
		led_byte[i] = 0x4f;
	  break;
	  case 4:
		led_byte[i] = 0x66;
	  break;
	  case 5:
		led_byte[i] = 0x6d;
	  break;
	  case 6:
		led_byte[i] = 0x7d;
	  break;
	  case 7:
		led_byte[i] = 0x07;
	  break;
	  case 8:
		led_byte[i] = 0x7f;
	  break;
	  case 9:
		led_byte[i] = 0x6f;
	  break;
	  default:
		led_byte[i] = 0x3f;
	  break;
	}
	i++;
  }
  i2c_start_wait(0x70+I2C_WRITE);
  i2c_write(0x01);
  i2c_write(led_byte[1]);
  i2c_write(led_byte[0]);
  i2c_stop();
}

int main(void) {
	unsigned int b;
	unsigned char c;
	unsigned char buf[127];
	//unsigned char rssi_ar[10];
	unsigned char i = 0, j = 0;
	unsigned int rssi = 0;
	
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
	
	i2c_start_wait(0x70+I2C_WRITE);
	i2c_write(0x01);
	i2c_write(0x3f);
	i2c_write(0x3f);
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
			
			if(c != 0) {
			 led_write(c); 
			}
			/*rssi_ar[i] = c;
			i++;
			if (i>9) {
			  rssi = 0;
			  qsort(rssi_ar, 10, sizeof(unsigned char), cmpfunc);
			  for(j = 1; j < 9; j++) {
				rssi += rssi_ar[j];
			  }
			  rssi /= 8;
			  led_write((unsigned char)rssi);
			  i = 0;
			}*/
			
        }
    }
	
	return 0;
}