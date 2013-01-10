/*
 * Copyright (c) 2005-2006 Rincon Research Corporation
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * - Redistributions of source code must retain the above copyright
 *   notice, this list of conditions and the following disclaimer.
 * - Redistributions in binary form must reproduce the above copyright
 *   notice, this list of conditions and the following disclaimer in the
 *   documentation and/or other materials provided with the
 *   distribution.
 * - Neither the name of the Rincon Research Corporation nor the names of
 *   its contributors may be used to endorse or promote products derived
 *   from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
 * FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE
 * ARCHED ROCK OR ITS CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
 * INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
 * STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
 * OF THE POSSIBILITY OF SUCH DAMAGE
 */
 
/**
 * Test for radio acknowledgements
 * Program all motes up with ID 1
 *   Led0 = Missed an ack
 *   Led1 = Got an ack
 *   Led2 = Sent a message
 * @author David Moss
 */
 
#include "stdlib.h"
#include "string.h"

module TestRssiP {
  
  provides {
		interface Msp430UartConfigure;
	}
  uses {
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
  
  /** Message to transmit */
  message_t myMsg;
  char str[] = "\x14RSSI:     ";
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
 * Uart Configuration
*****************************************************************************************/
#if defined(PLATFORM_TELOSB)
	msp430_uart_union_config_t msp430_uart_4800_config = {
    {
      utxe 	 : 1, 
	    urxe 	 : 1, 
      ubr 	 : UBR_1MHZ_4800,			// Baud rate (use enum msp430_uart_rate_t in msp430usart.h for predefined rates)
      umctl  : UMCTL_1MHZ_4800,		// Modulation (use enum msp430_uart_rate_t in msp430usart.h for predefined rates)
      ssel 	 : 0x02,							// Clock source (00=UCLKI; 01=ACLK; 10=SMCLK; 11=SMCLK)
      pena 	 : 0,									// Parity enable (0=disabled; 1=enabled)
      pev 	 : 0,									// Parity select (0=odd; 1=even)
      spb 	 : 0,									// Stop bits (0=one stop bit; 1=two stop bits)
      clen 	 : 1,									// Character length (0=7-bit data; 1=8-bit data)
      listen : 0,									// Listen enable (0=disabled; 1=enabled, feed tx back to receiver)
      mm 		 : 0,									// Multiprocessor mode (0=idle-line protocol; 1=address-bit protocol)
      ckpl 	 : 0,									// Clock polarity (0=normal; 1=inverted)
      urxse  : 0,									// Receive start-edge detection (0=disabled; 1=enabled)
      urxeie : 1,									// Erroneous-character receive (0=rejected; 1=recieved and URXIFGx set)
      urxwie : 0,									// Wake-up interrupt-enable (0=all characters set URXIFGx; 1=only address sets URXIFGx)
      utxe 	 : 1,									// 1:enable tx module
      urxe 	 : 1									// 1:enable rx module
    }
  };
#else
#error "Unknown platform"
#endif

	async command msp430_uart_union_config_t* Msp430UartConfigure.getConfig() {
    return &msp430_uart_4800_config;
  }

/*****************************************************************************************
 * Uart Usage
*****************************************************************************************/

	task void requestUART() {
		call Resource.request();						// Request UART Resource
	}
	
	task void releaseUART() {
    call Resource.release();						// Never used in this example
  }
	
	event void Resource.granted() {
		call UartStream.disableReceiveInterrupt();
		call UartStream.send((uint8_t *)str, 11);
	  
  }
  
  async event void UartStream.sendDone(uint8_t *buf, uint16_t len, error_t error) {
    call UartStream.enableReceiveInterrupt();
    post releaseUART();
  }
  
	async event void UartStream.receivedByte(uint8_t byte) {
	
	
  }
  
  async event void UartStream.receiveDone(uint8_t* buf, uint16_t len, error_t error) {
	
  }
  
  
  /***************** SplitControl Events ****************/
  event void SplitControl.startDone(error_t error) {
    post send();
  }
  
  event void SplitControl.stopDone(error_t error) {
  }
  
  /***************** Receive Events ****************/
  event message_t *Receive.receive(message_t *msg, void *payload, uint8_t len) {
    int8_t rssi;
    call Leds.led2Toggle();
    rssi = call CC2420Packet.getRssi(msg);
    itoa(rssi, str+7, 10);
    post requestUART();
    
    return msg;
  }
  
  /***************** AMSend Events ****************/
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
