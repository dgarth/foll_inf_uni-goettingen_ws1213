//vim: filetype=nc:tabstop=4:expandtab:shiftwidth=0:softtabstop=-1
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
 *   Led0 = Received a message
 *   Led1 = Got an ack
 *   Led2 = Missed an ack
 * @author David Moss
 */
 

configuration TestRssiC {
}

implementation {
  components TestRssiP as App,
      MainC,
      ActiveMessageC,
      CC2420ActiveMessageC,
      new AMSenderC(128),
      new AMReceiverC(128),
      new TimerMilliC(),
      LedsC;


      
  App.Boot -> MainC;
  App.SplitControl -> ActiveMessageC;
  App.Leds -> LedsC;
  App.AMSend -> AMSenderC;
  App.Receive -> AMReceiverC;
  App.PacketAcknowledgements -> ActiveMessageC;
  App.Timer -> TimerMilliC;
 App.CC2420Packet -> CC2420ActiveMessageC;
  
  // Uart
components new Msp430Uart0C() as UartC;
  App.Resource 					 	-> UartC.Resource;
  App.UartStream 				 	-> UartC.UartStream;
  App.Msp430UartConfigure <- UartC.Msp430UartConfigure;

}
