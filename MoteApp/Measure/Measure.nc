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
     * Signalled when setup was completed.
     *
     * @param <b>error</b> SUCCESS or FAIL
     */
    event void setupDone(error_t error);

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
     * @param <b>rssi</b> measured RSSI value in [0, 255]
     * @param <b>time</b> time of arrival
     */
    event void received(uint8_t rssi, uint32_t time);
}
