// vim: filetype=nc:tabstop=4:expandtab:shiftwidth=0:softtabstop=-1

// vim ft=nc

#include "../allnodes.h"

module MeasureTestC
{
    uses
    {
        interface NodeTools;
        interface Boot;
        interface Measure;
        interface Leds;
    }
}

implementation
{

    node_msg_t response;

    struct measure_options m_opts;

    event void Boot.booted(void)
    {
        call NodeTools.serialInit();

        /* run infinite test series between nodes 1 and 2 */
        m_opts.partner = TOS_NODE_ID ^ 0x3,
            m_opts.count = 0, call Measure.setup(m_opts);
    }

    event void Measure.setupDone(error_t error)
    {
        call Measure.start();
    }

    event void NodeTools.onSerialCommand(node_msg_t * cmd)
    {
        call Measure.setup(m_opts);
    }

    event void Measure.received(uint8_t rssi)
    {
        response.cmd = CMD_REPORT;
        response.data[0] = rssi;
        call Leds.led2Toggle();
        call NodeTools.enqueueMsg(&response);
    }

    event void Measure.stopped(void)
    {
        response.cmd = CMD_STOPMS;
        call NodeTools.enqueueMsg(&response);
    }
}
