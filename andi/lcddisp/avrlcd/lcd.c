

/*PC2=CE PC1=RW PC0=RS*/
#include <avr/io.h>
#include <util/delay.h>
#include "lcd.h"

/* Chip Select, wenn Daten gesetzt */
void lcd_enable( void ) {
    PORTC |= _BV(PC2);     // Enable auf 1 setzen
    _delay_us( 20 );  // kurze Pause
    PORTC &= ~_BV(PC2);    // Enable auf 0 setzen
}

/* LCD-Controller KS0070 initialisieren im 8-Bit Parallelmodus, nach Datenblatt */
void lcd_init(void) {
	DDRB = 0xFF;
	DDRC |= _BV(PC2) | _BV(PC1) | _BV(PC0);
	
	PORTB = 0x00;
	PORTC &= ~_BV(PC2) & ~_BV(PC1) & ~_BV(PC0);
	
	PORTB = 0x30;
	lcd_enable();
	
	_delay_ms( 5 );
 
    lcd_enable();
    _delay_ms( 1 );
 
    lcd_enable();
    _delay_ms( 1 );
    
    PORTB = 0x38;
    lcd_enable();
    
    _delay_ms(5);
    
    PORTB = 0x0C;
    lcd_enable();
    
    _delay_us(50);
    
    PORTB = 0x01;
    lcd_enable();
    
    _delay_ms(3);
    
    PORTB = 0x06;
    lcd_enable();
}

/* Chip zuruecksetzen */
void lcd_clear(void) {
	PORTB = 0x01;
	lcd_enable();
	_delay_ms(2);
}

/* Cursor an Speicherstelle pos setzen */
void lcd_setCursor(uint8_t pos) {
	pos &= 0b01111111;
	PORTB = 0x80 | pos;
	lcd_enable();
	_delay_us(50);
}

/* ein Zeichen an aktuelle Cursorstelle schreiben,	*
 * Cursor wird automatisch inkrementiert.			*/
void lcd_putc(char c) {
	PORTC |=  _BV(PC0);
	PORTB = c;
	lcd_enable();
	_delay_us(50);
	PORTC &=  ~_BV(PC0);
}

/* angegebene Zeile mit Spaces ueberschreiben und Cursor	*
 * auf ihren Anfang setzen									*/
void lcd_clearLine(uint8_t line) {
	uint8_t i;
	if((line == FIRST) || (line == SECOND)) {
		lcd_setCursor(line);
		for(i=0; i<16; i++)
			lcd_putc(' ');
		lcd_setCursor(line);
	} else
			lcd_clear();
}

/* Einen String auf den LCD schreiben */
void lcd_puts(const char *s, uint8_t line) {
	lcd_clearLine(line);
	while(*s != '\0')
		lcd_putc(*(s++));
}