// vim: filetype=nc:tabstop=4:expandtab:shiftwidth=0:softtabstop=-1


#include "../allnodes.h"
#include "../pack.h"

module MeasureMoteC
{
    uses
    {
        interface Boot;
        interface NodeComm;
        interface Measure;
    }
}

implementation
{

    uint16_t counter, current_series;

    uint8_t partner;
    bool setup_done;

    /*******************
     * USED INTERFACES *
     *******************/

    /*------*
     * Boot *
     *------*/

    event void Boot.booted(void)
    {
        call NodeComm.init();
    }


    /*----------*
     * NodeComm *
     *----------*/

    event void NodeComm.dissReceive(const node_msg_t *cmd)
    {
        uint8_t id1, id2;

        /* filter "uninteresting" commands */
        switch (cmd->cmd) {
            case CMD_NEWMEASURE:
            case CMD_STARTMS:
            case CMD_STOPMS:
                break;

            default:
                return;
        }

        unpack(cmd->data, "BB", &id1, &id2);

        /* command does not concern this node */
        if (id1 != TOS_NODE_ID && id2 != TOS_NODE_ID) {
            return;
        }

        /* handle command */
        if (cmd->cmd == CMD_NEWMEASURE) {
            struct measure_options opt;

            unpack(cmd->data, "__HH", &current_series, &opt.count);
            partner = opt.partner = (id1 == TOS_NODE_ID) ? id2 : id1;

            call Measure.setup(opt);
        }
        else if (cmd->cmd == CMD_STARTMS) {
            if (setup_done) {
                call Measure.start();
            }
        }
        else if (cmd->cmd == CMD_STOPMS) {
            call Measure.stop();
        }
    }

    event void NodeComm.collReceive(node_msg_t *cmd)
    {
    }


    /*---------*
     * Measure *
     *---------*/

    event void Measure.setupDone(error_t error)
    {
        if (error == SUCCESS) {
            setup_done = TRUE;
        }
        else {
            setup_done = FALSE;
        }
    }

    event void Measure.received(uint8_t rssi)
    {
        node_msg_t cmd;

        cmd.cmd = CMD_REPORT;
        cmd.length =
            pack(cmd.data, "BBHHB", TOS_NODE_ID, partner, current_series,
                 counter, rssi);
        call NodeComm.collSend(&cmd);

        counter++;
    }

    event void Measure.stopped(void)
    {
        current_series = 0;
        counter = 0;
    }
}
