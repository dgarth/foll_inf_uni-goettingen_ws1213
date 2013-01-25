// vim: filetype=nc:tabstop=4:expandtab:shiftwidth=0:softtabstop=-1

#ifndef MEASURE_H
#define MEASURE_H

enum
{
    RSSI_OFFSET = -45,
    MEASURE_INTERVAL = 1000,
};

struct measure_options
{
    uint8_t partner;

    uint16_t count;
};

#endif
