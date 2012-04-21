Arduino Firmware
---------------------
* Firmware sources are in the "src" folder.
* Compilated binaries for the differents arduino boards are in the "binaries" folder

If you just want to upload the firmware, go to the binaries folder and follows the intructions given in the README file.
If you want to modify the firmware sources, go to the src folder and follows the instructions given in the README file.


Command List
--------------------------
### Principle
Basically, a command contains two fields, an integer which represents the kind of command, and a string containing all the required aguments. The end of the command is given by the char ";"
### Set pin mode
Configures the specified pin to behave either as an input or an output.

* **id** : 4
* **parameters** : pin mode
  * **pin** : the pin number
  * **mode** : in / input / out / output
* **return** : nothing

*example : Set the pin 13 in output mode*

```
4 13 out; 
```

### Digital write
Write a HIGH or a LOW value to a digital pin.

* **id** : 5
* **parameters** : pin value
  * **pin** : the pin number
  * **value** : low / 0 / high / 1
* **return** : nothing

*example : Write HIGH on the pin 13*

```
5 13 high; 
```

### Digital read 
Read a HIGH or a LOW value from a digital pin.

* **id** : 6
* **parameters** : pin
  * **pin** : the pin number
* return : 6 pin value

*example : Read a high value on pin 13*

```
6 13; =>  6 13 1
```

### Analog read 
Read an analog value from an analog pin.
The returned value is a float with a two digit precision (we use a 100 oversampling factor)

* **id** : 7
* **parameters** : pin
  * **pin** : the pin number
* return : 7 pin value

*example : Read an analog value on pin 2*

```
7 2; =>  7 2 456.00
```

### Pwm write
Writes an analog value (PWM wave) to a pin

* **id** : 8
* **parameters** : pin value
  * **pin** : the pin number
  * **value** : the value to write (from 0 to 255)
* return : nothing

*example : Write a 102 on pin 3*

```
8 3 102;
```

### RCswitch write
Writes an tri-state code on a pin according to the rcswitch library
 

* **id** : 9
* **parameters** : pin code
  * **pin** : the pin number
  * **code** : tri-state code
* return : nothing

*example : Write a FFFFF0FFFF0F on pin 11*

```
9 11 FFFFF0FFFF0F;
```
### Dht11 read
Read a value on a dht11 sensor

* **id** : 10
* **parameters** : pin
  * **pin** : the pin number
* return : 10 pin humidity temperature

*example : Write a 102 on pin 3*

```
10 3; => 10 3 68.00 22.00
```

Arduino Libraries
---------------------
The openplacos firmware for arduino use the following libraries

* CmdMessenger : http://arduino.cc/playground/Code/CmdMessenger
* RCSwitch : http://code.google.com/p/rc-switch/
* dht11 : http://arduino.cc/playground/Main/DHT11Lib

The libraries are packaged with the sources, you don't need to install them.
