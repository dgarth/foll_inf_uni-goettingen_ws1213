// vim: filetype=nc:tabstop=4:expandtab:shiftwidth=0:softtabstop=-1

#include "Measure.h"

interface Measure
{
    /**
     * Set parameters for the next test series.
     *
     * If necessary, initializes other needed components.
     *
     * @param <b>opt</b> options for the test series
     */
    command void setup(struct measure_options opt);

    /**
     * Start test series with current configuration.
     *
     * @return
     *  <li> SUCCESS if test series was started
     *  <li> FAIL if a test series is already running or setup() was never
     *       called
     */
    command error_t start(void);

    /**
     * Stop currently running test series.
     *
     * Does nothing if there is no test series running.
     */
    command void stop(void);

    /**
     * Signalled when a test series is stopped.
     *
     * reasons for stopping can be:
     *  <li> Measure.stop() was called
     *  <li> the configured packet limit was reached
     */
    event void stopped(void);


    /**
     * Signalled when a measure packet was received.
     *
     * @param <b>rssi</b> measured RSSI value
     */
    event void received(uint16_t measure, uint16_t counter, int8_t rssi);
    
    /**
     * Signalled when a measure packet was sent.
     *
     * @param <b>count</b> number of packet sent
     */
    event void sent(uint16_t count);
}
