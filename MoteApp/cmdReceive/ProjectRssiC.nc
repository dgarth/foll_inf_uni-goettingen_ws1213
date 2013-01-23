//vim: filetype=nc:tabstop=4:expandtab:shiftwidth=0:softtabstop=-1
#include "Timer.h"
#include "CC2420.h"

#include "ProjectRssi.h"
#include "../allnodes.h"
#include "../Measure/Measure.h"

#define RED 1
#define GREEN 2
#define BLUE 4

module ProjectRssiC @safe()
{
    uses interface Leds;
    uses interface Boot;

    uses interface Timer<TMilli> as Timer0;
    uses interface CC2420Packet;

    uses interface Packet;
    uses interface AMPacket;
    uses interface SplitControl as AMControl;
    // Zum Testen von Collection erstmal rausgenommen
    //uses interface Receive;
    //uses interface AMSend;

    uses interface NodeTools;
    uses interface Measure;
    
    /* Dissemination krams */
    uses interface StdControl as DisControl;
    
    uses interface DisseminationUpdate<node_msg_t> as DisUpdate;
    uses interface DisseminationValue<node_msg_t> as DisMsg;

    /* Collection krams */
    uses interface StdControl as RoutingControl;
    uses interface Send as ColSend;
    uses interface Receive as ColReceive;
    uses interface RootControl;

    
}

implementation
{
    uint8_t myID;
    uint8_t partnerID;
	uint8_t led;
    bool busy = FALSE;
    message_t pktToBeSend;
    message_t pkt;
    node_msg_t* ourPayload;
    error_t result;
        
    struct measure_options opts = {
        .partner = 0,
        .count = 0,
    };

    event void Boot.booted()
    {
        /* target ID wird doch ueber die Node ID gemacht??
        * also kann myAddr kram weg!?!?
        * Nein, Toni meint, dass TOS_NODE_ID und AMPACKET.address()
        * das gleiche sind.
		//am_addr_t myAddr;
		//myAddr = call AMPacket.address();
        */

        myID = call AMPacket.address();
        
        call AMControl.start();

        /*
        //Das hab ich erstmal ins startDone event gepackt,
        //damit man sicher sein kann, dass AMControl gestartet ist
        if(!busy){
            ourPayload= (node_msg_t*) call Packet.getPayload(&pktToBeSend, sizeof(node_msg_t));
            ourPayload->cmd=CMD_LEDON;
            ourPayload->data[0]=1;
            ourPayload->data[1]=1;
            result = call AMSend.send(AM_BROADCAST_ADDR, &pktToBeSend, sizeof(node_msg_t));
            if(result == SUCCESS)
                call Leds.led0On();
            else
                call Leds.led2On();
        }
        */
        //if(call AMSend.send(AM_BROADCAST_ADDR, ,sizeof(node_msg_t))== SUCCESS)
            //call Leds.led1On();
            
        // call Timer0.startPeriodic(500);
        //call Leds.led1On();
    } 
    event void Measure.setupDone(error_t error) {
        call Measure.start();
    }

    event void NodeTools.onSerialCommand(node_msg_t* cmd) {
        struct measure_options serialOpts = {
            .partner = cmd->data[0],
            .count = 0,
        };
        call Measure.setup(serialOpts);
    }
    event void Measure.received(uint8_t rssi) {
        //call NodeTools.sendResponse(NULL);
    }
    event void Measure.stopped(void) {
        //call NodeTools.sendResponse(NULL);
    }

    event void AMControl.startDone(error_t err)
    {
        if (err == SUCCESS)
        {
            call RoutingControl.start();
            if ( myID == 10 ) {
               call RootControl.setRoot();
            }
            else {
               call Timer0.startPeriodic(500); 
            }
        }
        else
        {
            call AMControl.start();
        }
    }
    event void AMControl.stopDone(error_t err)
    {
    }
    // kann auch weg, wenns laeuft
    event void Timer0.fired()
    {
        if(!busy){
            ourPayload= (node_msg_t*) call Packet.getPayload(&pktToBeSend, sizeof(node_msg_t));
            ourPayload->cmd=CMD_LEDON;
            ourPayload->data[0]=1;
            ourPayload->data[1]=1;
            result = call ColSend.send(&pktToBeSend, sizeof(node_msg_t));
            if(result == SUCCESS)
                call Leds.led0On();
            else
                call Leds.led2On();
        }
    /* 
        if (!busy)
        {
            ProjectRssiMsg *msg = call Packet.getPayload(&pktToBeSend, sizeof (ProjectRssiMsg));
            msg->nodeid = 12; // msg nach pkt 
            if (call AMSend.send(AM_BROADCAST_ADDR, &pktToBeSend, sizeof(ProjectRssiMsg)) == SUCCESS)
            {
                printf("Sende Packet\n");
                printfflush();
                busy = TRUE;
            }
        }*/
    }
    
    event void ColSend.sendDone(message_t *msg, error_t error) {
        if (&pktToBeSend == msg)
        {
            busy = FALSE;
            /* Debug kram, kann weg wenn ausprobiert */
            ourPayload= (node_msg_t*) call Packet.getPayload(msg, sizeof(node_msg_t));
            if(ourPayload->cmd==CMD_LEDON)
                call Leds.led1On();
        }

    }

    event void DisMsg.changed(){
       const node_msg_t *newMsg = call DisMsg.get();
        /* Hier kommt jetzt der update kram rein 
        * Nicht in AMSend/Receive und so weiter...
        *
        * Wenn Nachricht empfangen wird:
        * 1. Pruefen obs ne node_msg_t ist, mittels len
        * 2. Hole Payload also node_msg_t 
        * 3. Checke ob fuer mich
        * 4. Wenn nein: Sende weiter! So einfach gehts nicht...
        * 5. Wenn ja: Fuehre Cmd aus
        * 6. Profit :)
        */

        

        /* "native" Kommandos implementieren, benutzerdefinierte weiterreichen */
        switch (newMsg->cmd) {
            case CMD_LEDON:
                if (newMsg->data[0] == myID) {
                    led = newMsg->data[1];
                    call NodeTools.setLed(led, TRUE);
                }
                break;

            case CMD_LEDOFF:
                if (newMsg->data[0] == myID) {
                    led = newMsg->data[1];
                    call NodeTools.setLed(led, FALSE);
                }
                break;

            case CMD_LEDTOGGLE:
                if (newMsg->data[0] == myID) {
                    led = newMsg->data[1];
                    if (call Leds.get() && led) {
                        call NodeTools.setLed(led, FALSE);
                    } else {
                        call NodeTools.setLed(led, TRUE);
                    }
                }
                break;

            case CMD_LEDBLINK:
                if (newMsg->data[0] == myID) {
                    led = newMsg->data[1];
                    call NodeTools.flashLed(led, newMsg->data[2]);
                }
                break;
            case CMD_NEWMEASURE:
                if ( newMsg->data[0] == myID ) {
                    opts.partner = newMsg->data[1];
                }
                if ( newMsg->data[1] == myID ){
                    opts.partner = newMsg->data[0];
                }

                opts.count = 0;
                
                call Measure.setup(opts);
                break;


        }
    }
    
    
    event message_t *ColReceive.receive(message_t *msg, void *payload, uint8_t len)
    {

        if ( len != sizeof(node_msg_t) ) {
			return msg;
		}
        
        /* Collection Test */
        ourPayload= (node_msg_t*) call Packet.getPayload(msg, sizeof(node_msg_t));
        if ( ourPayload->cmd == CMD_LEDON ){
            call NodeTools.setLed(ourPayload->data[1], TRUE);
        }
        /* Hier sollen nur Sachen gemacht werden, um Daten zum Computer
        * zu uebertragen!
        * cmds werden ueber das Dissemination interface verteilt!
        */

        return msg;
    }
}

