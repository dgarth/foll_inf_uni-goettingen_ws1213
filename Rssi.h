#ifndef RSSI_H
#define RSSI_H

/* some constants */
#define BEACON_PERIOD 2000
enum { AM_BEACONMSG, AM_RSSIMSG, AM_COLLECT };

#define LED_COLLECT 0
#define LED_SERIAL  LED_COLLECT
#define LED_BEACON  1
#define LED_RCV     2


/* struct definitions */
typedef nx_struct BeaconMsg
{
    nx_uint16_t nodeid;
    nx_uint16_t counter;
} BeaconMsg;

typedef nx_struct RssiMsg
{
    nx_uint16_t
        source,
        destination,
        counter,
        rssi;
} RssiMsg;


/* "nicer" interface for controlling LEDs */
#define LEDCMD(n, cmd) call Leds.led ## n ## cmd()
#define led_on(n) LEDCMD(n, On)
#define led_off(n) LEDCMD(n, Off)
#define led_toggle(n) LEDCMD(n, Toggle)

#endif
