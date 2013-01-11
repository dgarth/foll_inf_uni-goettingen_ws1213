#ifndef LCDDISP_H
#define LCDDISP_H

#define LCDDISP_LEN 16

enum
{
    // "commands"
    LCDDISP_CLEAR_LINE1 = 0x13,
    LCDDISP_CLEAR_LINE2 = 0x14,
    LCDDISP_NOP         = 0x16,

    // "events"
    LCDDISP_BUTTON1     = 0x11,
    LCDDISP_BUTTON2     = 0x12,
};

#endif
