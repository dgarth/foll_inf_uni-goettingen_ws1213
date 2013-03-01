// vim: filetype=nc:tabstop=4:expandtab:shiftwidth=0:softtabstop=-1

#ifndef MEASURE_H
#define MEASURE_H

enum
{
    RSSI_OFFSET = -45,
};

struct measure_options
{
    uint8_t partner;
    uint16_t measure;
    uint16_t count;
    uint16_t interval;
};

nx_struct measure_msg {
    nx_uint16_t measure;
    nx_uint16_t counter;
};

#endif
