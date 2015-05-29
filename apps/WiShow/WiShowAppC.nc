configuration WiShowAppC
{
}
implementation
{
	// general
	components WiShowC as App;
	components MainC;
	components LedsC;
	
	App.Boot -> MainC;
	App.Leds -> LedsC;
	
	//FOr writing into serial port
	components SerialPrintfC;
	
	//radioComm
	components ActiveMessageC;
	components new AMSenderC(AM_RADIO);
	components new AMReceiverC(AM_RADIO);
	
	App.Packet -> AMSenderC;
	App.AMPacket -> AMSenderC;
	App.AMSend -> AMSenderC;
	App.AMControl -> ActiveMessageC;
	App.Receive -> AMReceiverC; 
}