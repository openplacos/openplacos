#include <Messenger.h>

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
     Serial.print("pin ");
     Serial.print(pin);
     Serial.print(" ");
     Serial.print(val);
     Serial.print("\n");
     return;
   }
   
 }

 if ( message.checkString("adc") ) {
   int pin = message.readInt();
   int val = analogRead(pin);    // read the input pin
   Serial.print("adc ");
   Serial.print(pin);
   Serial.print(" ");
   Serial.println(val);
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
  Serial.begin(115200); 
  // Attach the callback function to the Messenger
  message.attach(messageReady);
}


void loop() {
  // The following line is the most effective way of using Serial and Messenger's callback
  while ( Serial.available() )  message.process(Serial.read () );
}
