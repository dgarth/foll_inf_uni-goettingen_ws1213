#ifndef HORST_H
#define HORST_H
typedef nx_struct RadioMsg
{
    nx_uint16_t nodeid;
    nx_uint16_t count;
} RadioMsg;

typedef nx_struct SerialMsg
{
    nx_uint16_t nodeid;
    nx_uint16_t count;
    nx_uint16_t rssi;
} SerialMsg;

enum { AM_RADIOMSG=4, AM_SERIALMSG };

#define TIMER_PERIOD 3000
#endif
