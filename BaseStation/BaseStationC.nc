#include "../Rssi.h"
#include <AM.h>

module BaseStationC
{
    uses
    {
        interface Boot;
        interface Leds;

        interface SplitControl as RadioControl;

        interface RootControl;
        interface StdControl as CollectionControl;
        interface Receive as CollectionReceive;

        interface StdControl as DissControl;
        interface DisseminationUpdate<nx_struct Settings> as Settings;

        interface SplitControl as SerialControl;
        interface AMSend as SerialSend;

        interface Timer<TMilli>;
    }
}

implementation
{
    nx_struct Settings settings = SETTINGS_DEFAULT;

    bool serial_busy = FALSE;

    message_t serial_pkt;

    void next(void)
    {
        settings.series++;
        if (!settings.series)
            settings.series = 1;
        led_on(LED_BEACON);
        call Settings.change(&settings);
    }

    void pause(void)
    {
        nx_struct Settings s = settings;
        s.series = 0;
        led_off(LED_BEACON);
        call Settings.change(&s);
    }

    event void Boot.booted(void)
    {
        call RadioControl.start();
        call SerialControl.start();
    }

    event void SerialSend.sendDone(message_t *msg, error_t error)
    {
        if (msg == &serial_pkt) {
            led_off(LED_SERIAL);
            serial_busy = FALSE;
        }
    }

    event message_t *CollectionReceive.receive(message_t *msg, void *payload, uint8_t len)
    {
        nx_struct RssiMsg
            *inmsg = payload,
            *outmsg;

        if (serial_busy || len != sizeof *inmsg) {
            return msg;
        }

        led_toggle(LED_RCV);
        inmsg = payload;

        /* get pointer to outgoing packet payload */
        outmsg = call SerialSend.getPayload(&serial_pkt, sizeof *outmsg);
        if (!outmsg) {
            return msg;
        }

        /* copy message */
        *outmsg = *inmsg;

        /* send via serial */
        if (call SerialSend.send(AM_BROADCAST_ADDR, &serial_pkt, sizeof *outmsg) == SUCCESS) {
            led_on(LED_SERIAL);
            serial_busy = TRUE;
        }

        if (inmsg->counter >= 10) {
            pause();
            call Timer.startOneShot(5000);
        }

        return msg;
    }

    event void RadioControl.startDone(error_t err)
    {
        if (err == SUCCESS) {
            call CollectionControl.start();
            call DissControl.start();
            call RootControl.setRoot();
            next();
        }
        else {
            call RadioControl.start();
        }
    }

    event void RadioControl.stopDone(error_t err)
    {
    }

    event void SerialControl.startDone(error_t err)
    {
        if (err == SUCCESS) {
        }
        else {
            call SerialControl.start();
        }
    }

    event void SerialControl.stopDone(error_t err)
    {
    }

    event void Timer.fired(void)
    {
        next();
    }
}
