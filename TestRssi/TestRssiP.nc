/*********************************************************************************
 * Abwandlung von TestACK aus den tinyos Quellen, wobei der RSSI Wert der Pakete *
 * ausgelesen und auf dem seriellen Display ausgegeben wird.					 *
 *********************************************************************************/
#include "stdlib.h"
#include "string.h"

module TestRssiP {	
	provides {
		interface Msp430UartConfigure;
	} uses {
		interface Boot;
		interface SplitControl;
		interface AMSend;
		interface Receive;
		interface Leds;
		interface PacketAcknowledgements;
		interface Timer<TMilli>;
		interface CC2420Packet;
		// Uart
		interface Resource;
		interface UartStream;
	}
}

implementation {
	
	/*Globale Variablen*/
	message_t myMsg;
	char str[] = "\x14RSSI:			";
	uint8_t sbuf[13];
	enum {	
		DELAY_BETWEEN_MESSAGES = 50,
	};
	
	
	/***************** Prototypes ****************/
	task void send();
	task void requestUART();
	task void releaseUART();
	
	/***************** Boot Events ****************/
	event void Boot.booted() {
		call SplitControl.start();
		post requestUART();
	}

	/*****************************************************************************************
 	* Uart Configuration, gesetzt auf 8N1-Modus bei 4800 Baud, entsprechend dem Display
 	*****************************************************************************************/
	msp430_uart_union_config_t msp430_uart_4800_config = {
		{
			utxe	 : 1, 
			urxe	 : 1, 
			ubr		 : UBR_1MHZ_4800,			// Baud rate (use enum msp430_uart_rate_t in msp430usart.h for predefined rates)
			umctl	 : UMCTL_1MHZ_4800,		// Modulation (use enum msp430_uart_rate_t in msp430usart.h for predefined rates)
			ssel	 : 0x02,							// Clock source (00=UCLKI; 01=ACLK; 10=SMCLK; 11=SMCLK)
			pena	 : 0,									// Parity enable (0=disabled; 1=enabled)
			pev		 : 0,									// Parity select (0=odd; 1=even)
			spb		 : 0,									// Stop bits (0=one stop bit; 1=two stop bits)
			clen	 : 1,									// Character length (0=7-bit data; 1=8-bit data)
			listen : 0,									// Listen enable (0=disabled; 1=enabled, feed tx back to receiver)
			mm		 : 0,									// Multiprocessor mode (0=idle-line protocol; 1=address-bit protocol)
			ckpl	 : 0,									// Clock polarity (0=normal; 1=inverted)
			urxse	 : 0,									// Receive start-edge detection (0=disabled; 1=enabled)
			urxeie : 1,									// Erroneous-character receive (0=rejected; 1=recieved and URXIFGx set)
			urxwie : 0,									// Wake-up interrupt-enable (0=all characters set URXIFGx; 1=only address sets URXIFGx)
			utxe	 : 1,									// 1:enable tx module
			urxe	 : 1									// 1:enable rx module
		}
	};
		
	async command msp430_uart_union_config_t* Msp430UartConfigure.getConfig() {
		return &msp430_uart_4800_config;
	}

	/*****************************************************************************************
	 * Uart Usage
	 *****************************************************************************************/

	task void requestUART() {
		call Resource.request();						// UART anfordern
	}
	
	task void releaseUART() {
		call Resource.release();						// UART freigeben
	}
	
	/* Wenn wir den UART haben: */
	event void Resource.granted() {
		call UartStream.send((uint8_t *)str, 11); //unseren vorher aufbereiteten String senden
		
	}
	
	/*Nach dem Senden UART fuer Funk freigeben*/
	async event void UartStream.sendDone(uint8_t *buf, uint16_t len, error_t error) {
		post releaseUART();
	}
	
	async event void UartStream.receivedByte(uint8_t byte) {
		// Hier koennte man auf die Tastknoepfe reagieren (byte == 0x11 || byte == 0x12)
		// dazu muesste man wohl ab und an den UART requesten und mit dem releasen etwas warten.
		// Evtl. reicht aber schon die Zeit, die er zum Senden des Strings aus. Ist ja bidirektional.
		// Ziemlich nervig, aber unsere Motes sind halt so gebaut.
	}
	
	async event void UartStream.receiveDone(uint8_t* buf, uint16_t len, error_t error) {
		//Hier koennte man laengere Nachrichten ueber den UART empfangen, fuer uns wohl eher uninteressant
	}
	
	
	/***************** SplitControl Events ****************/
	event void SplitControl.startDone(error_t error) {
		post send();
	}
	
	event void SplitControl.stopDone(error_t error) {
	}
	
	/***************** Receive Events fuer Funk ****************/
	event message_t *Receive.receive(message_t *msg, void *payload, uint8_t len) {
		int8_t rssi;
		call Leds.led2Toggle();
		rssi = call CC2420Packet.getRssi(msg); //RSSI auslesen
		itoa(rssi, str+7, 10);	//RSSI als ASCII-Code in str schreiben
		post requestUART();		//den UART requesten, um str zu senden
		
		return msg;
	}
	
	/***************** AMSend Events fuer Funk ****************/
	event void AMSend.sendDone(message_t *msg, error_t error) {
		if(call PacketAcknowledgements.wasAcked(msg)) {
			call Leds.led1Toggle();
			call Leds.led0Off();
		} else {
			call Leds.led0Toggle();
			call Leds.led1Off();
		}
		
		if(DELAY_BETWEEN_MESSAGES > 0) {
			call Timer.startOneShot(DELAY_BETWEEN_MESSAGES);
		} else {
			post send();
		}
	}
	
	/***************** Timer Events ****************/
	event void Timer.fired() {
		post send();
	}
	
	/***************** Tasks ****************/
	task void send() {
		call PacketAcknowledgements.requestAck(&myMsg);
		if(call AMSend.send(1, &myMsg, 0) != SUCCESS) {
			post send();
		}
	}
}
