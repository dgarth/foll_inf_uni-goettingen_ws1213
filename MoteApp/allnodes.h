// vim: filetype=nc:tabstop=4:expandtab:shiftwidth=0:softtabstop=-1

/* allnodes.h - definiert das, was für alle Nodes gleich bleibt. */

#ifndef ALLNODES_H
#define ALLNODES_H

/* LED-Nummern für Leds.set() */
#define LED_RED 1
#define LED_GREEN 2
#define LED_BLUE 4

#define MONITOR_ID 9
#define SINK_ID 10


/*** Kommandos ***/
enum commands {
    S_OK = 1,
    /* Generic "OK" packet.
       Parameters: None. */

    CMD_ECHO,
    /* Echo request & response.
       Request Parameters:
       data = ID list (multiping), uint8[]
       Response parameters:
       data[0] = ID (cc2420 address) */

    CMD_LEDON,
    /* Switch LED on. Parameters:
       data[0] = target ID, uint8
       data[1] = LED (0, 1, 2), uint8 */

    CMD_LEDOFF,
    /* Switch LED off. Parameters:
       data[0] = target ID, uint8
       data[1] = LED (0, 1, 2), uint8 */

    CMD_LEDTOGGLE,
    /* Toggle LED. Parameters:
       data[0] = target ID, uint8
       data[1] = LED (0, 1, 2), uint8 */

    CMD_LEDBLINK,
    /* Blink (flash) LED. Parameters:
       data[0] = target ID, uint8
       data[1] = LED (0, 1, 2), uint8
       data[2] = blink count, uint8 */

    CMD_NEWMS,
    /* Initiate a new measure between two nodes. Parameters:
       data[0] = ID1 (sending node), uint8
       data[1] = ID2 (receiving node), uint8
       data[2]...data[3] = Messreihe, uint16
       data[4]...data[5] = Anzahl Messpakete, uint16
       -> format "BBHH"
     */

    CMD_STARTMS,
    /* Start a measure initiated with CMD_NEWMS.
       data[0] = ID1 (sending node), uint8
       data[1] = ID2 (receiving node), uint8 */

    CMD_STOPMS,
    /* Stop a measure between node1 and node2. Parameters:
       data[0] = ID1 (sending node), uint8
       data[1] = ID2 (receiving node), uint8 */

    CMD_CLEARMS,
    /* Lose a measure parnership initiated with CMD_NEWMS. Parameters:
       data[0] = ID1 (sending node), uint8
       data[1] = ID2 (receiving node), uint8 */

    CMD_REPORT,
    /* Report a measure result to the sink. Parameters:
       data[0] = ID (reporting node ID), uint8
       data[1] = Partner ID (andere ID in CMD_NEWMS), uint8
       data[2]...data[3] = Messreihe, uint16
       data[4]...data[5] = Nummer der Messung, uint16
       data[6] = RSSI value, int8
       -> format "BBHHb"
     */

    DEBUG_OUTPUT,
    /* Print debug output to MoteConsole.
       data = (string) */
};

#define MAX_DATA 10

typedef nx_struct node_msg {
	/* Kommando */
	nx_uint8_t cmd;
	/* Daten oder Parameter */
	nx_uint8_t data[MAX_DATA];
	/* Länge der gültigen Daten */
	nx_uint8_t length;
	/* 1, falls das nächste Paket weitere
	 * Daten enthält, sonst 0. */
	nx_uint8_t moreData;
} node_msg_t;

enum {
	AM_NODE_MSG = 0x89,
	AM_MEASURE = 42,
	AM_COLLECTION = 0xee,
	AM_DISS_NODEMSG = 0x1234,
	AM_MONITOR = 13
};

#endif
