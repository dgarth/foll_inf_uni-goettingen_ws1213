//vim: filetype=nc:tabstop=4:expandtab:shiftwidth=0:softtabstop=-1
#define LCD_H
#endif
#define FIRST 0x00
#define SECOND 0x40

extern void lcd_enable( void ) ;
extern void lcd_init( void ) ;
extern void lcd_clear( void ) ;
extern void lcd_setCursor( uint8_t pos ) ;
extern void lcd_putc( char c ) ;
extern void lcd_clearLine( uint8_t line ) ;
extern void lcd_puts( const char *s, uint8_t line ) ;