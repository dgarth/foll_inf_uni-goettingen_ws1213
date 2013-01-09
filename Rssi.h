#ifndef RSSI_H
#define RSSI_H

/* some constants */
#define BEACON_PERIOD 2000
enum { AM_BEACONMSG, AM_RSSIMSG, AM_COLLECT };

#define LED_COLLECT LEDS_LED0
#define LED_SERIAL  LED_COLLECT
#define LED_BEACON  LEDS_LED1
#define LED_RCV     LEDS_LED2


/* struct definitions */
nx_struct BeaconMsg
{
    nx_uint16_t nodeid;
    nx_uint16_t counter;
};

nx_struct RssiMsg
{
    nx_uint16_t
        source,
        destination,
        series,
        counter,
        rssi;
};


/* "nicer" interface for controlling LEDs */
#define LEDCMD(cmd) call Leds.set(call Leds.get() cmd)
#define led_on(n) LEDCMD(| (n))
#define led_off(n) LEDCMD(& ~(n))
#define led_toggle(n) LEDCMD(^ (n))

#endif
