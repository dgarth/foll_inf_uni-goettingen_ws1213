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
    bool
        radio_ready=FALSE,
        radio_busy=FALSE,
        running=FALSE;

    message_t pkt;

    uint16_t counter;

    struct {
        uint8_t partner;
        uint16_t series;
        uint32_t time;
        uint16_t interval;
        uint16_t count;
    } config;

    task void stop(void);

    command void Measure.setup(uint8_t partner, uint16_t series, uint32_t time, uint16_t interval, uint16_t count)
    {
        counter = 0;

        config.partner = partner;
        config.series = series;
        config.time = time;
        config.interval = interval;
        config.count = count;

        call RadioControl.start();
    }

    command error_t Measure.start(void)
    {
        if (!radio_ready || running) {
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
            radio_ready = TRUE;
            signal Measure.setupDone(SUCCESS);
        }
        else {
            call RadioControl.start();
        }
    }

    event void RadioControl.stopDone(error_t err)
    {
        if (err == SUCCESS) {
            radio_ready = FALSE;
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

        rssi = RssiPacket.getRssi(msg);
        now = Timer.getNow();

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
