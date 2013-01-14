/* allnodes.h - definiert das, was für alle Nodes gleich bleibt. */

#ifndef ALLNODES_H
#define ALLNODES_H

/* LED-Nummern für Leds.set() */
#define LED_RED 1
#define LED_GREEN 2
#define LED_BLUE 4

/*** Kommandos ***/
#define CMD_ECHO 1
/* Echo request. Parameters:
data = ID list (multiping), uint8[] */

#define CMD_LEDON 2
/* Switch LED on. Parameters:
data[0] = target ID, uint8
data[1] = LED (0, 1, 2), uint8 */

#define CMD_LEDOFF 3
/* Switch LED off. Parameters:
data[0] = target ID, uint8
data[1] = LED (0, 1, 2), uint8 */

#define CMD_LEDTOGGLE 4
/* Toggle LED. Parameters:
data[0] = target ID, uint8
data[1] = LED (0, 1, 2), uint8 */

#define CMD_LEDBLINK 5
/* Blink (flash) LED. Parameters:
data[0] = target ID, uint8
data[1] = LED (0, 1, 2), uint8
data[2] = blink count, uint8 */

#define CMD_NEWMEASURE 6
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

#define CMD_STARTMS 7
/* Start a measure initiated with CMD_NEWMEASURE.
data[0] = ID1 (sending node), uint8
data[1] = ID2 (receiving node), uint8 */

#define CMD_STOPMS 8
/* Stop a measure between node1 and node2. Parameters:
data[0] = ID1 (sending node), uint8
data[1] = ID2 (receiving node), uint8 */

#define CMD_CLEARMS 9
/* Lose a measure parnership initiated with CMD_NEWMEASURE. Parameters:
data[0] = ID1 (sending node), uint8
data[1] = ID2 (receiving node), uint8 */

#define CMD_REPORT 10
/* Report a measure result to the sink. Parameters:
data[0] = ID (reporting node ID), uint8
data[1]...data[2] = Messreihe, uint16
data[3]...data[6] = Zeit seit Startzeit (ms), uint32
data[7] = RSSI value, uint8
data[8] = Partner ID (andere ID in CMD_NEWMEASURE), uint8 */

#define CMD_USERCMD 11
/* Send user command. Parameters:
data = command (string) */

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
#define flushMsg(...) printf(__VA_ARGS__);printfflush()

#endif
