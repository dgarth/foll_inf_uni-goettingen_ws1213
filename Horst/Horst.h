#ifndef HORST_H
#define HORST_H
typedef nx_struct RadioMsg
{
    nx_uint16_t nodeid;
    nx_uint16_t count;
} RadioMsg;

enum { AM_RADIOMSG=4, AM_RSSIMSG };

#define TIMER_PERIOD 3000
#endif
