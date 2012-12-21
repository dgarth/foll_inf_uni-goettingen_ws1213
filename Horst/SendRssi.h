#ifndef SENDRSSI_H
#define SENDRSSI_H

#include <AM.h>

enum { SENDRSSI_DEST = AM_BROADCAST_ADDR };

typedef nx_struct RssiMsg
{
    nx_uint16_t
        source,
        counter,
        rssi;
} RssiMsg;

#endif
