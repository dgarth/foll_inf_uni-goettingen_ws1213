/* allnodes.h - definiert das, was für alle Nodes gleich bleibt. */

#ifndef ALLNODES_H
#define ALLNODES_H

/* LED-Nummern für Leds.set() */
#define LED_RED 1
#define LED_GREEN 2
#define LED_BLUE 4

/*** Kommandos ***/
#define S_OK 1
/* Generic "OK" packet.
Parameters: None. */

#define CMD_ECHO 2
/* Echo request & response.
Request Parameters:
data = ID list (multiping), uint8[]
Response parameters:
data[0] = ID (cc2420 address) */

#define CMD_LEDON 3
/* Switch LED on. Parameters:
data[0] = target ID, uint8
data[1] = LED (0, 1, 2), uint8 */

#define CMD_LEDOFF 4
/* Switch LED off. Parameters:
data[0] = target ID, uint8
data[1] = LED (0, 1, 2), uint8 */

#define CMD_LEDTOGGLE 5
/* Toggle LED. Parameters:
data[0] = target ID, uint8
data[1] = LED (0, 1, 2), uint8 */

#define CMD_LEDBLINK 6
/* Blink (flash) LED. Parameters:
data[0] = target ID, uint8
data[1] = LED (0, 1, 2), uint8
data[2] = blink count, uint8 */

#define CMD_NEWMEASURE 7
/* Initiate a new measure between two nodes. Parameters:
data[0] = ID1 (sending node), uint8
data[1] = ID2 (receiving node), uint8
data[2]...data[3] = Messreihe, uint16
data[4]...data[7] = Startzeit (ms relativ), uint32
data[8] = Anzahl Optionen (uint8)
data[9]...data[12] = DWORD (uint32) Option "opt", mit
LOWORD(opt) = 0: keine Optionen
LOWORD(opt) = 1: Anzahl Messungen in HIWORD(opt)
LOWORD(opt) = 2: Monitor Node in HIWORD(opt)
...further Options (uint32) */

#define CMD_STARTMS 8
/* Start a measure initiated with CMD_NEWMEASURE.
data[0] = ID1 (sending node), uint8
data[1] = ID2 (receiving node), uint8 */

#define CMD_STOPMS 9
/* Stop a measure between node1 and node2. Parameters:
data[0] = ID1 (sending node), uint8
data[1] = ID2 (receiving node), uint8 */

#define CMD_CLEARMS 10
/* Lose a measure parnership initiated with CMD_NEWMEASURE. Parameters:
data[0] = ID1 (sending node), uint8
data[1] = ID2 (receiving node), uint8 */

#define CMD_REPORT 11
/* Report a measure result to the sink. Parameters:
data[0] = ID (reporting node ID), uint8
data[1]...data[2] = Messreihe, uint16
data[3]...data[6] = Zeit seit Startzeit (ms), uint32
data[7] = RSSI value, uint8
data[8] = Partner ID (andere ID in CMD_NEWMEASURE), uint8 */

#define DEBUG_OUTPUT 12
/* Print debug output to MoteConsole.
data = (string) */

#define MAX_DATA 25

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
	AM_MEASURE = 42
};

/* Makros */
#define makeWORD(array, index) ((array[index+1] << 8) | array[index])
#define makeDWORD(array, index) (((uint32_t) array[index+3] << 24) | ((uint32_t) array[index+2] << 16) | (array[index+1] << 8) | array[index])

#endif
