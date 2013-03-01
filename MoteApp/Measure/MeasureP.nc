// vim: filetype=nc:tabstop=4:expandtab:shiftwidth=0:softtabstop=-1

#include "Measure.h"

module MeasureP
{
    provides interface Measure;

    uses
    {
        interface Timer<TMilli>;
        interface Random;

        interface SplitControl as RadioControl;
        interface AMSend as Send;
        interface Receive;

        interface AMPacket;
        interface CC2420Packet as RssiPacket;
    }
}

implementation
{
    /****************************
     * TASK/FUNCTION PROTOTYPES *
     ****************************/

    /* stop currently running test series (or do nothing) */
    task void stop(void);


    /**********************
     * EXTERNAL VARIABLES *
     **********************/

    bool radio_started = FALSE, radio_busy = FALSE, running = FALSE;

    struct measure_options config;

    /* number of dummies sent */
    uint16_t counter;

    /* message for sending dummy packet */
    message_t pkt;


    /*********************************
     * TASK/FUNCTION IMPLEMENTATIONS *
     *********************************/

    task void stop(void)
    {
        running = FALSE;
        call Timer.stop();
        signal Measure.stopped();
    }


    /***********************
     * PROVIDED INTERFACES *
     ***********************/

    /*---------*
     * Measure *
     *---------*/

    command void Measure.setup(struct measure_options opt)
    {
        /* set options */
        config = opt;

        /* reset counter */
        counter = 0;

        /* try to start up the radio */
        switch (call RadioControl.start()) {

            case EALREADY:
                /* radio already started -> good! */
                radio_started = TRUE;
                break;

            case SUCCESS:
                /* startDone will be signalled -> do nothing for now */
                break;

            case EBUSY:
            case FAIL:
                /* can't start radio -> bad */
                radio_started = FALSE;
                break;
        }
    }

    command error_t Measure.start(void)
    {
        uint32_t o;
        if (!radio_started || running) {
            return FAIL;
        }

        running = TRUE;
        o = call Random.rand16() % config.interval;
        call Timer.startPeriodicAt(call Timer.getNow() + o, config.interval);
        return SUCCESS;
    }

    command void Measure.stop(void)
    {
        post stop();
    }


    /*******************
     * USED INTERFACES *
     *******************/

    /*-------*
     * Timer *
     *-------*/

    event void Timer.fired(void)
    {
        nx_struct measure_msg *msg;
        if (radio_busy) {
            return;
        }

        msg = call Send.getPayload(&pkt, sizeof *msg);

        msg->measure = config.measure;
        msg->counter = counter;

        /* send an empty dummy packet */
        if (call Send.send(config.partner, &pkt, sizeof *msg) == SUCCESS) {
            radio_busy = TRUE;
        }

        /* stop measuring if limit reached */
        if (config.count && ++counter >= config.count) {
            post stop();
        }
    }


    /*------*
     * Send *
     *------*/

    event void Send.sendDone(message_t *msg, error_t error)
    {
        if (msg == &pkt) {
            signal Measure.sent(counter);
            radio_busy = FALSE;
        }
    }


    /*---------*
     * Receive *
     *---------*/

    event message_t *Receive.receive(message_t *msg, void *payload,
                                     uint8_t len)
    {
        int8_t rssi;
        nx_struct measure_msg *p = payload;

        /* get sender node ID */
        am_addr_t source = call AMPacket.source(msg);

        /* is the message OK (a dummy packet from our partner)? */
        if (len == sizeof *p && source == config.partner) {
            rssi = call RssiPacket.getRssi(msg) + RSSI_OFFSET;
            signal Measure.received(p->measure, p->counter, rssi);
        }
        return msg;
    }


    /*--------------*
     * RadioControl *
     *--------------*/

    event void RadioControl.startDone(error_t err)
    {
        if (err == SUCCESS) {
            radio_started = TRUE;
        }
    }

    event void RadioControl.stopDone(error_t err)
    {
        if (err == SUCCESS) {
            radio_started = FALSE;
        }
    }

}
