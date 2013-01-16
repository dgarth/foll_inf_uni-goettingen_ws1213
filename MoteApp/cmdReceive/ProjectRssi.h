#ifndef PROJECT_RSSI_H
#define PROJECT_RSSI_H

enum {
    AM_BLINKTORADIO = 6,
    TIMER_PERIOD_MILLI = 250
};

typedef nx_struct ProjectRssiMsg {
    nx_uint16_t nodeid;
} ProjectRssiMsg;

#endif
