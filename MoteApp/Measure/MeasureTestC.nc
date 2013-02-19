// vim: filetype=nc:tabstop=4:expandtab:shiftwidth=0:softtabstop=-1

#include "../allnodes.h"
#include "../pack.h"

module MeasureTestC
{
    uses
    {
        interface NodeTools;
        interface Boot;
        interface Measure;
    }
}

implementation
{

    node_msg_t resp;
    uint16_t series = 0, counter = 0;

    struct measure_options m_opts = {
        .partner = 0,
        .count = 0,
    };

    event void Boot.booted(void)
    {
        call NodeTools.serialInit();

        /* start bidirectional test series between 1 and 2 */
        m_opts.partner = TOS_NODE_ID ^ 0x3;
        call Measure.setup(m_opts);
        call Measure.start();
    }

    event void NodeTools.onSerialCommand(node_msg_t *cmd)
    {
        call Measure.setup(m_opts);
    }

    event void Measure.received(int8_t rssi)
    {
        resp.cmd = CMD_REPORT;
        resp.length = pack(resp.data, "BBHHb",
                           TOS_NODE_ID, m_opts.partner, series, counter,
                           rssi);
        counter++;

        call NodeTools.enqueueMsg(&resp);
    }
    
    event void Measure.send(uint16_t counter)
    {
    }

    event void Measure.stopped(void)
    {
    }
}
