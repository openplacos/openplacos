#include <Messenger.h>
#include <NewSoftSerial.h>   //Software Serial Port
#define RxD 11
#define TxD 12
#define BAUPRATE 38400
 
#define DEBUG_ENABLED  1
 
NewSoftSerial blueToothSerial(RxD,TxD);
// Instantiate Messenger object with the default separator (the space character)
Messenger message = Messenger(); 

// Create the callback function
void messageReady() {
 
 while ( message.available() ) {
  
 if ( message.checkString("pin") ) {
   int pin = message.readInt();
   
   if (message.checkString("out") or message.checkString("output")) { // pin #pinnumber out
     pinMode(pin,OUTPUT);
     return;
   }
   if (message.checkString("in") or message.checkString("input")) { // pin #pinnumber in
     pinMode(pin,INPUT);
     return;
   }   
   if (message.checkString("low") or message.checkString("0")) {  // pin #pinnumber 0
     digitalWrite(pin,0);
     return;
   }
   if (message.checkString("high") or message.checkString("1")) {  // pin #pinnumber 1
     digitalWrite(pin,1);
     return;
   }
   if (message.checkString("state")) {  // pin #pinnumber state
     int val = digitalRead(pin);
     blueToothSerial.print("pin ");
     blueToothSerial.print(pin);
     blueToothSerial.print(" ");
     blueToothSerial.print(val);
     blueToothSerial.print("\n");
     return;
   }
   
 }

 if ( message.checkString("adc") ) {
   int pin = message.readInt();
   int val = analogRead(pin);    // read the input pin
   blueToothSerial.print("adc ");
   blueToothSerial.print(pin);
   blueToothSerial.print(" ");
   blueToothSerial.println(val);
   return;  
 }  
 
 if ( message.checkString("led") ) {
   int pin = 13;
   if (message.checkString("off") ) {  
     digitalWrite(pin,0);
     return;
   }
   if (message.checkString("on")) { 
     digitalWrite(pin,1);
     return;
   }  
 }
 
 if ( message.checkString("pwm") ) {
   int pin = message.readInt();
   int duty = message.readInt();
   analogWrite(pin,duty);
   return;  
 }  
 

 message.readInt();
 }      

}


void setup() {
  // Initiate Serial Communication
  pinMode(RxD, INPUT);
  pinMode(TxD, OUTPUT);
  setupBlueToothConnection();
  // Attach the callback function to the Messenger
  message.attach(messageReady);
}


void loop() {
  // The following line is the most effective way of using Serial and Messenger's callback
  while ( blueToothSerial.available() )  message.process(blueToothSerial.read() ); 
 
}
 
void setupBlueToothConnection()
{
    blueToothSerial.begin(BAUPRATE); //Set BluetoothBee BaudRate to default baud rate
    delay(1000);
    sendBlueToothCommand("\r\n+STWMOD=0\r\n");
    sendBlueToothCommand("\r\n+STNA=SeeeduinoBluetooth\r\n");
    //sendBlueToothCommand("\r\n+STBD=BAUPRATE\r\n");
    sendBlueToothCommand("\r\n+STAUTO=0\r\n");
    sendBlueToothCommand("\r\n+STOAUT=1\r\n");
    sendBlueToothCommand("\r\n +STPIN=0000\r\n");
    delay(2000); // This delay is required.
    sendBlueToothCommand("\r\n+INQ=1\r\n");
    delay(2000); // This delay is required.
}
 
//Checks if the response "OK" is received
void CheckOK()
{
  char a,b;
  while(1)
  {
    if(blueToothSerial.available())
    {
    a = blueToothSerial.read();
 
    if('O' == a)
    {
      // Wait for next character K. available() is required in some cases, as K is not immediately available.
      while(blueToothSerial.available()) 
      {
         b = blueToothSerial.read();
         break;
      }
      if('K' == b)
      {
        break;
      }
    }
   }
  }
 
  while( (a = blueToothSerial.read()) != -1)
  {
    //Wait until all other response chars are received
  }
}
 
void sendBlueToothCommand(char command[])
{
    blueToothSerial.print(command);
    CheckOK();   
}

