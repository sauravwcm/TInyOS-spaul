#include <Timer.h>
#include <stdio.h>
#include <string.h>
#include "WiShow.h"
module WiShowC
{
	uses 
	{
		//general
		interface Boot;
		interface Leds;
		
		//for Radio comms
		interface Packet;
		interface AMPacket;
		interface AMSend;
		interface SplitControl as AMControl;
		interface Receive;
	}
	
}
implementation
{
	
	uint16_t centiGrade;
	bool radioBusy= FALSE;
	//uint16_t  notemp=0; 
	message_t packet;

	event void Boot.booted()
	{
		call Leds.led1On();
		call AMControl.start();
	}
	
	event message_t * Receive.receive(message_t *msg, void *payload, uint8_t len)
	{
		if(len == sizeof(WsnMsg_t))
		{
			WsnMsg_t * incomingPacket = (WsnMsg_t*) payload;
			//incomingPacket ->NodeID == 2;
			uint16_t data = incomingPacket -> Data ;
			
			if(data == 0)
			{
				printf("error \r\n");
					
			}	
			else
			{
				call Leds.led1Off();
				centiGrade = -39.6 + 0.01 * data;
				//display received temp
				printf("current temp is: %d \r\n ",centiGrade);
				call Leds.led2Toggle();
				if(radioBusy==FALSE)
			{
 				//creating packet
				WsnMsg_t* msg= call Packet.getPayload(& packet, sizeof(WsnMsg_t));
				msg -> NodeID= TOS_NODE_ID;
				msg -> Data = 5; 		
				
				//sending the packet
	 			if(call AMSend.send(2, & packet, sizeof(WsnMsg_t))==SUCCESS)
	 			{
	 				radioBusy=TRUE;
	 			}	
	 		}
			}
				
		}
		return msg;
	}

	event void AMSend.sendDone(message_t *msg, error_t error)
	{
		if(msg == & packet)
		{
			radioBusy = FALSE;
		}
	}

	event void AMControl.stopDone(error_t error)
	{
		// TODO Auto-generated method stub
	}

	event void AMControl.startDone(error_t error)
	{
		if(error==SUCCESS)
		{
			call Leds.led0On();
		}
		else
		{
			call AMControl.start();
		}
	}
}