// Das vi-Syntaxhighlighting funktioniert (bei mir) nur mit diesem seltsamen Kommentar-Konstrukt am Anfang.

/** Und um einen kommentar zu dokumentieren, macht man einen kommentar oben drueber? :D
**/

#include "../allnodes.h"

module MeasureTestC {
    uses {
        interface NodeTools;
        interface Boot;
        /*interface Timer<TMilli> as Timer;*/
        interface Measure;
        interface Leds;
    }
}

implementation {

    node_msg_t response;

    struct measure_options m_opts = {
        .partner = 0,
        .interval = 500,
        .count = 0,
    };

    event void Boot.booted(void) {
        call NodeTools.serialInit();

        /* start bidirectional test series between 1 and 2 */
        m_opts.partner = TOS_NODE_ID ^ 0x3;
        call Measure.setup(m_opts);
    }
    
    event void Measure.setupDone(error_t error) {
        call Measure.start();
    }

    event void NodeTools.onSerialCommand(node_msg_t* cmd) {
        call Measure.setup(m_opts);
    }

    event void Measure.received(uint8_t rssi, uint32_t time) {
        response.cmd = CMD_REPORT;
        response.data[0] = rssi;
        call Leds.led2Toggle();
        call NodeTools.sendResponse(&response);
    }
    
    event void Measure.stopped(void) {
        response.cmd = CMD_STOPMS;
        call NodeTools.sendResponse(&response);
    }
}
