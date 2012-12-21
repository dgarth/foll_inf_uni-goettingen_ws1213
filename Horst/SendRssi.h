#ifndef SENDRSSI_H
#define SENDRSSI_H

typedef nx_struct RssiMsg
{
    nx_uint16_t
        source,
        counter,
        rssi;
} RssiMsg;

#endif
