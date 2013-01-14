#include "../allnodes.h"

module MeasureTestAppC {
    uses {
        interface NodeTools
        interface Boot
        interface Timer<TMilli> as Timer
        interface Measure
    }
} implementation {
    event void Boot.booted(void) {
        command NodeTools.serialInit();
    }

    event void NodeTools.onCommand(node_msg* cmd) {
        uint8_t partner = cmd->data[0];
        uint16_t series = cmd->data[2] + cmd->data[3]<<8;
        uint16_t interval = 500;
        uint16_t count = 0;
        command Measure.setup(partner, series, time, interval, count)		
    }

    event void Measure.received(uint8_t rssi, uint32_t time) {
        char resp = (char) rssi;
        command NodeTools.sendResponse(&resp)
    }
}
