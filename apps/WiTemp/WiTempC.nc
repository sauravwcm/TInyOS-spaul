#include "WiTemp.h"
module WiTempC
{
	uses
	{
		//general
		interface Boot;
		interface Leds;
		interface Timer<TMilli>;
		
		//read temperature
		interface Read<u_int16_t> as TempRead;
		
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
	
	bool radioBusy= FALSE;
	uint8_t  notemp=0; 
	message_t packet;

	event void Boot.booted()
	{
		call Timer.startPeriodic(1000);
		call Leds.led1On();
		call AMControl.start();
	}

	event void Timer.fired()
	{
		
		call Leds.led1Off();
		if(call TempRead.read() == SUCCESS)
		{
			call Leds.led2Toggle();
		}
		else
		{
		 	call Leds.led0Toggle();
		}
	}

	event void TempRead.readDone(error_t result, u_int16_t val)
	{

    val= val>>8;
		if(result == SUCCESS)
		{	
			
			if(radioBusy==FALSE)
			{
 				//creating packet
				WsnMsg_t* msg= call Packet.getPayload(& packet, sizeof(WsnMsg_t));
				msg -> NodeID= TOS_NODE_ID;
				msg -> Data = (uint8_t)val; 		
				
				//sending the packet
	 			if(call AMSend.send(AM_BROADCAST_ADDR, & packet, sizeof(WsnMsg_t))==SUCCESS)
	 			{
	 				radioBusy=TRUE;
	 			}	
	 		}
	 	}
	 	else
	 	{
	 		if(radioBusy==FALSE)
			{
 				//creating packet
				WsnMsg_t* msg= call Packet.getPayload(& packet, sizeof(WsnMsg_t));
				msg -> NodeID= TOS_NODE_ID;
				msg -> Data = notemp; 		
				
				//sending the packet
	 			if(call AMSend.send(AM_BROADCAST_ADDR, & packet, sizeof(WsnMsg_t))==SUCCESS)
	 			{
	 				radioBusy=TRUE;
	 			}	
	 		}
	 	}	
	}

	event void AMSend.sendDone(message_t *msg, error_t error)
	{
		if(msg == & packet)
		{
			radioBusy = FALSE;
		}
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

	event message_t * Receive.receive(message_t *msg, void *payload, uint8_t len)
	{
		if(len == sizeof(WsnMsg_t))
		{
			WsnMsg_t * incomingPacket = (WsnMsg_t*) payload;
			//incomingPacket ->NodeID == 1;
			uint8_t data = incomingPacket -> Data ;
			
			if(data == 5)// acknowledgement data
			{
				call Leds.led1Toggle();
					
			}	
			else
			{
				call Leds.led1Off();
			}
				
		}
		return msg;
	}

	event void AMControl.stopDone(error_t error){
		// TODO Auto-generated method stub
	}
}