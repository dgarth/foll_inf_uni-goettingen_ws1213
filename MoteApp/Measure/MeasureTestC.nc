#include "../allnodes.h"

module MeasureTestC {
    uses {
        interface NodeTools;
        interface Boot;
        /*interface Timer<TMilli> as Timer;*/
        interface Measure;
    }
}

implementation {
    event void Boot.booted(void) {
        call NodeTools.serialInit();
    }
    
    event void Measure.setupDone(error_t error) {
        call Measure.start();
    }

    event void NodeTools.onCommand(node_msg_t* cmd) {
        struct measure_options opts = {
            .partner = cmd->data[0],
            .series = cmd->data[2] + (cmd->data[3] << 8),
            .interval = 500,
            .count = 0,
        };
        call Measure.setup(opts);
    }

    event void Measure.received(uint8_t rssi, uint32_t time) {
        call NodeTools.sendResponse(NULL);
    }
    
    event void Measure.stopped(void) {
        call NodeTools.sendResponse(NULL);
    }
}
