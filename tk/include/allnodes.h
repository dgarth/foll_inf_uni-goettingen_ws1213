/* allnodes.h - definiert das, was für alle Nodes gleich bleibt. */

#ifndef ALLNODES_H
#define ALLNODES_H

/* IDs von bekannten Nodes (die anderen haben 1-6) */
#define RELAY_ID 9
#define SINK_ID 10

/* LED-Nummern für Leds.set() */
#define LED_RED 1
#define LED_GREEN 2
#define LED_BLUE 4

/*** Control-Messages ***/
#define CTRL_PING 1 /* Echo Request */
#define CTRL_NEWMEASURE 2 /* neue Messreihe */
#define CTRL_RSSIDATA 4
/*	data1 = Absender
	data2 = Empfänger
	data3 = RSSI-Wert zwischen Sender und Empfänger */
#define CTRL_REPLY 8
/*	data1 = errno */

typedef nx_struct RFMessage {
	nx_uint8_t control; /* Status- und Kontrolldaten */
	nx_uint8_t sender; /* Absender dieser Nachricht (NodeID) */
	nx_uint8_t data1;
	nx_uint8_t data2;
	nx_int8_t data3;
} RFMessage;

/* Makros */
#define flushMsg(...) printf(__VA_ARGS__);printfflush()

#endif

