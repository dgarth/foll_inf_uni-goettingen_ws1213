
#ifndef CONSOLE_MSG_H
#define CONSOLE_MSG_H

typedef nx_struct console_msg {
	/* Kommando */
	nx_uint8_t cmd;
	/* Daten oder Parameter */
	nx_uint8_t data[25];
	/* Länge der gültigen Daten */
	nx_uint8_t length;
	/* 1, falls das nächste Paket weitere
	 * Daten enthält, sonst 0. */
	nx_uint8_t moreData;
} console_msg_t;

enum {
	AM_CONSOLE_MSG = 0x89,
};

#endif
