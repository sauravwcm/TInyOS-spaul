

#include "AM.h"
#include "Serial.h"
#include "WiTemp.h"
//#include "msp430usart.h"

module SendSerP {
  uses {
    interface Boot;
    interface SplitControl as SerialControl;

    interface UartByte;
    interface UartStream;
    
    interface Timer<TMilli>;

    interface Leds;
  }
}

implementation
{


  uint8_t ser_byte;
  uint16_t length=1;

  
  event void Boot.booted() {		// initialization

    call SerialControl.start();
    call Timer.startPeriodic(200);
    //call UartStream.enableReceiveInterrupt();
    call UartStream.receive(&ser_byte, length);
  }

  event void Timer.fired()
  {
    //call Leds.led2Toggle();

    //if(call UartByte.receive(&ser_byte,timeout) == SUCCESS)
      //call Leds.led0Toggle();
    //else
      //call Leds.led1Toggle();  
  }

  
  async event void UartStream.receivedByte(uint8_t byte)
  {
    call Leds.led2Toggle();
    call UartByte.send(byte);

    if(byte>100)
      {
        call Leds.led0On();
        call Leds.led1Off();
      } 
    else
      {
        call Leds.led1On();
        call Leds.led0Off();
      }
  }

  async event void UartStream.receiveDone(uint8_t *buf, uint16_t len, error_t error)
  {
    call Leds.led0Toggle();
  }

  async event void UartStream.sendDone(uint8_t *buf, uint16_t len, error_t error)
  {

  }

  event void SerialControl.startDone(error_t error) 
  {
    if(error == SUCCESS)
    {  
    
    }
    else
    {
      call SerialControl.start();
    }  
  }

  event void SerialControl.stopDone(error_t error) {}
  
  

}	// end implementation
