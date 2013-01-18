#ifndef LCDCONTROL_H
#define LCDCONTROL_H


enum
{
    // "commands"
    LCD_CLEAR_LINE1 = 0x13,
    LCD_CLEAR_LINE2 = 0x14,
    LCD_NOP         = 0x16,
    LCD_LED1		= 0x11,
    LCD_LED2		= 0x12,
    LCD_BEEP		= 0x07,

    // "events"
    LCD_BUTTON1     = 0x11,
    LCD_BUTTON2     = 0x12
};
#endif