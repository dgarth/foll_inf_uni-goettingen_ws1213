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
        interface NodeTools;
    }
}

implementation
{
    uint8_t partner;
    bool setup_done = FALSE;

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
            case CMD_NEWMS:
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
        if (cmd->cmd == CMD_NEWMS) {
            struct measure_options opt;

            unpack(cmd->data, "__HHH", &opt.measure, &opt.count, &opt.interval);
            partner = opt.partner = (id1 == TOS_NODE_ID) ? id2 : id1;

            call Measure.setup(opt);
            setup_done = TRUE;
            call NodeTools.setLed(LED_GREEN, TRUE);
        }
        else if (cmd->cmd == CMD_STARTMS) {
            if (setup_done) {
                call Measure.start();
                call NodeTools.setLed(LED_BLUE, TRUE);
                call NodeTools.setLed(LED_GREEN, FALSE);
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

    event void Measure.received(uint16_t measure, uint16_t counter, int8_t rssi)
    {
        node_msg_t cmd;        
        static uint8_t received_count;

        cmd.cmd = CMD_REPORT;
        cmd.length =
            pack(cmd.data, "BBHHb", TOS_NODE_ID, partner, measure,
                 counter, rssi);
                 
        call NodeComm.collSend(&cmd);
        if (received_count++ % 0x10 == 0)
            call NodeTools.flashLed(LED_RED, 1);
    }

    event void Measure.stopped(void)
    {
        call NodeTools.setLed(LED_BLUE, FALSE);
		setup_done = FALSE;
    }
    
    event void Measure.sent(uint16_t count)
    {
        static uint8_t sent_count;
        if (sent_count++ % 0x10 == 0)
            call NodeTools.flashLed(LED_GREEN, 1);
    }

    /*-----------*
     * NodeTools *
     *-----------*/

    event void NodeTools.onSerialCommand(node_msg_t* cmd)
    {
    }
}
