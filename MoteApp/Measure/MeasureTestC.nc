#include "../allnodes.h"

module MeasureTestC {
    uses {
        interface NodeTools;
        interface Boot;
        /*interface Timer<TMilli> as Timer;*/
        interface Measure;
    }
} implementation {
    event void Boot.booted(void) {
        call NodeTools.serialInit();
    }
    
    event void Measure.setupDone(error_t error) {
    
    }

    event void NodeTools.onCommand(node_msg_t* cmd) {
        uint8_t partner = cmd->data[0];
        uint16_t series = cmd->data[2] + cmd->data[3]<<8;
        uint16_t interval = 500;
        uint16_t count = 0;
        uint32_t time = 0;
        call Measure.setup(partner, series, time, interval, count);
        call Measure.start();
    }

    event void Measure.received(uint8_t rssi, uint32_t time) {
        call NodeTools.sendResponse(NULL);
    }
    
    event void Measure.stopped(void) {
        call NodeTools.sendResponse(NULL);
    }
}
