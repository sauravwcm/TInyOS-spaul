configuration SendSerC {
}
implementation {
  components MainC, SendSerP, LedsC, PlatformSerialC;
  components SerialActiveMessageC as Serial;
  components new TimerMilliC();
	  

  SendSerP.Timer -> TimerMilliC;

  MainC.Boot <- SendSerP;

  SendSerP.SerialControl -> Serial;
  
  
  SendSerP.UartStream -> PlatformSerialC;
  SendSerP.UartByte -> PlatformSerialC;
  
  SendSerP.Leds -> LedsC;
}
