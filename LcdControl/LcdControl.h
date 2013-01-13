#ifndef LCDCONTROL_H
#define LCDCONTROL_H

#define LCD_LEN 16

enum
{
    // "commands"
    LCD_CLEAR_LINE1 = 0x13,
    LCD_CLEAR_LINE2 = 0x14,
    LCD_NOP         = 0x16,

    // "events"
    LCD_BUTTON1     = 0x11,
    LCD_BUTTON2     = 0x12,
};


#include <stdarg.h>
#include <stdio.h>

#define BUFFERS 3
static char *_lcdprintf(const char *fmt, ...)
{
    /* use LCD_LEN+1 because vsnprintf adds a null byte */
    static char buf[LCD_LEN+1][BUFFERS];
    static int i = 0;

    va_list ap;

    i = (i+1) % BUFFERS;

    va_start(ap, fmt);
    vsnprintf(buf[i], sizeof buf[i], fmt, ap);
    va_end(ap);

    return buf[i];
}
#undef BUFFERS

#define lcdprintf(...) puts(_lcdprintf(__VA_ARGS__))

#endif
