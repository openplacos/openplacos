// 
//    FILE: dht11.h
// VERSION: 0.3.2
// PURPOSE: DHT11 Temperature & Humidity Sensor library for Arduino
// LICENSE: GPL v3 (http://www.gnu.org/licenses/gpl.html)
//
// DATASHEET: http://www.micro4you.com/files/sensor/DHT11.pdf
//
//     URL: http://arduino.cc/playground/Main/DHT11Lib
//
// HISTORY:
// George Hadjikyriacou - Original version
// see dht.cpp file
// 

#ifndef dht11_h
#define dht11_h

#include "WProgram.h"

#define DHT11LIB_VERSION "0.3.2"

class dht11
{
public:
	int read(int pin);
	int humidity;
	int temperature;
};
#endif
//
// END OF FILE
//
