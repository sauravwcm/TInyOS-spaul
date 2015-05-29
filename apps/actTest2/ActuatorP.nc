/*** ACTUATOR ***/
// Annie I-An Chen
// 2009/3/9

// This application receives packages over the signal and
//   stores the most currently received message_t package on the RAM.
// When the PC prompts for this package by sending a package of length 1 containing the number 126(=0x7e),
//   the mote then sends the stored package via UART to the PC serial port to which it is connected.


#include "AM.h"
#include "Serial.h"
#include "WiTemp.h"

module ActuatorP {
  uses {
    interface Boot;
    interface SplitControl as SerialControl;
    interface SplitControl as RadioControl;

    interface AMSend as UartSend[am_id_t id];
    interface Packet as UartPacket;
    interface AMPacket as UartAMPacket;
    
    interface AMSend as RadioSend[am_id_t id];
    interface Receive as RadioReceive[am_id_t id];
    interface Receive as RadioSnoop[am_id_t id];
    interface Packet as RadioPacket;
    interface AMPacket as RadioAMPacket;

    interface Leds;
  }
}

implementation
{

  message_t  Data;					// most recently received message_t package
  message_t  *DataPtr = &Data;		// pointer to most recently received message_t package

  task void uartSendTask();			// send package over serial port

  void dropBlink() {				// toggle yellow LED to indicate dropped package
    call Leds.led2Toggle();
  }

  void failBlink() {
    call Leds.led2Toggle();			// toggle yellow LED to indicate failure during transmission
  }

  event void Boot.booted() {		// initialization
    call RadioControl.start();
    call SerialControl.start();
  }

  event void RadioControl.startDone(error_t error) {}
  event void SerialControl.startDone(error_t error) {}

  event void SerialControl.stopDone(error_t error) {}
  event void RadioControl.stopDone(error_t error) {}

  message_t* receive(message_t* msg, void* payload, uint8_t len);	// receive package through radio
  
  event message_t *RadioSnoop.receive[am_id_t id](message_t *msg,
						    void *payload,
						    uint8_t len) {
    return receive(msg, payload, len);
  }
  
  event message_t *RadioReceive.receive[am_id_t id](message_t *msg,
						    void *payload,
						    uint8_t len) {
    return receive(msg, payload, len);
  }

  message_t* receive(message_t *msg, void *payload, uint8_t len) {	// receive package through radio
    message_t *ret;

	if(len == sizeof(WsnMsg_t))
	{
		{
			WsnMsg_t * incomingPacket = (WsnMsg_t*) payload;
			uint8_t data = incomingPacket -> Data ;
			
			if(data == 200)// acknowledgement data
			{
				call Leds.led2Toggle();
					
			}	
			else
			{
				call Leds.led2Off();
			}
				
		}
	}
	atomic{
		ret = DataPtr;
		DataPtr = msg;
	}
	call Leds.led1Toggle();			// toggle green LED to indicate success in receiving a radio package
	
	post uartSendTask();

    return ret;						// return next available buffer for receiving packages
  }

  uint8_t tmpLen;
  
  task void uartSendTask() {		// send package through UART to serial port
    uint8_t len;
    am_id_t id;
    am_addr_t addr;
    message_t* msg;					// pointer to package to be sent

    msg = DataPtr;
    tmpLen = len = call RadioPacket.payloadLength(msg);
    id = call RadioAMPacket.type(msg);
    addr = call RadioAMPacket.destination(msg);

    if (call UartSend.send[id](addr, msg, len) == SUCCESS)
      call Leds.led0Toggle();		// toggle red LED to indicate success in sending a UART package
    else
      {
	failBlink();
	post uartSendTask();			// try again if failed
      }
  }

  event void UartSend.sendDone[am_id_t id](message_t* msg, error_t error) {
    if (error != SUCCESS)
      failBlink();
  }

  
  event void RadioSend.sendDone[am_id_t id](message_t* msg, error_t error) {}

}	// end implementation
