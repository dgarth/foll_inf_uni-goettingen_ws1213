#ifndef MEASURE_H
#define MEASURE_H

enum
{
    RSSI_OFFSET = -45
};

struct measure_options
{
    uint8_t
        partner;

    uint16_t
        interval,
        count;
};

#endif
