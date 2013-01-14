interface Measure
{
    command void setup(uint8_t partner, uint16_t series, uint32_t time, uint16_t interval, uint16_t count);
    event void setupDone(error_t error);

    command error_t start(void);
    command error_t stop(void);

    event void received(uint8_t rssi, uint32_t time);
}
