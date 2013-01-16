module MeasureP
{
    provides interface Measure;

    uses
    {
        interface Timer<TMilli>;

        interface SplitControl as RadioControl;
        interface AMPacket;
        interface AMSend as Send;
        interface Receive;

        interface CC2420Packet as RssiPacket;
    }
}

implementation
{
    task void stop(void);

    bool
        setup_done=FALSE,
        radio_busy=FALSE,
        running=FALSE;

    struct measure_options config = { 0 };
    uint16_t counter;

    message_t pkt;

    command void Measure.setup(struct measure_options opt)
    {
        counter = 0;
        config = opt;

        /* try to start up the radio */
        switch (call RadioControl.start()) {

            /* radio already started -> good! */
            case EALREADY:
                signal Measure.setupDone(SUCCESS);
                break;

            /* startDone will be signalled -> do nothing for now */
            case SUCCESS:
                break;

            /* can't start radio -> bad */
            case EBUSY:
            case FAIL:
                signal Measure.setupDone(FAIL);
                break;
        }
    }

    command error_t Measure.start(void)
    {
        if (!setup_done || running) {
            return FAIL;
        }

        running = TRUE;
        call Timer.startPeriodic(config.interval);
        return SUCCESS;
    }

    task void stop(void)
    {
        running = FALSE;
        call Timer.stop();
        signal Measure.stopped();
    }

    command void Measure.stop(void)
    {
        post stop();
    }

    event void RadioControl.startDone(error_t err)
    {
        if (err == SUCCESS) {
            setup_done = TRUE;
        }
        signal Measure.setupDone(err);
    }

    event void RadioControl.stopDone(error_t err)
    {
        if (err == SUCCESS) {
            setup_done = FALSE;
        }
    }

    event message_t *Receive.receive(message_t *msg, void *payload, uint8_t len)
    {
        uint8_t rssi;
        uint32_t now;
        am_addr_t source = call AMPacket.source(msg);

        if (len != 0 || !running || source != config.partner) {
            return msg;
        }

        rssi = call RssiPacket.getRssi(msg);
        now = call Timer.getNow();

        signal Measure.received(rssi, now);
        return msg;
    }

    event void Timer.fired(void)
    {
        if (radio_busy) {
            return;
        }

        if (call Send.send(config.partner, &pkt, 0) == SUCCESS) {
            radio_busy = TRUE;
        }

        if (config.count && counter++ >= config.count) {
            post stop();
        }
    }

    event void Send.sendDone(message_t *msg, error_t error)
    {
        if (msg == &pkt) {
            radio_busy = FALSE;
        }
    }
}
