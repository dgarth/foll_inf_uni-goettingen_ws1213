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

    event void RadioControl.startDone(error_t err)
    {
        if (err == SUCCESS) {
            ready = TRUE;
        }
        else {
            call RadioControl.start();
        }
    }

    event void RadioControl.stopDone(error_t err)
    {
        if (err == SUCCESS) {
            ready = FALSE;
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
    }

    event void CollectionSend.sendDone(message_t *msg, error_t error)
    {
        led_off(LED_COLLECT);
        collect_busy = FALSE;
    }

    event void Timer.fired(void)
    {
        if (radio_busy) {
            return;
        }

        if (call BeaconSend.send(config.partner, &pkt, 0) == SUCCESS) {
            radio_busy = TRUE;
        }
    }

    event void BeaconSend.sendDone(message_t *msg, error_t error)
    {
        if (msg == &pkt) {
            radio_busy = FALSE;
        }
    }
}
