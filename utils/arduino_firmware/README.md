Arduino Firmware
---------------------
* Firmware sources are in the "src" folder.
* Compilated binaries for the differents arduino boards are in the "binaries" folder

If you just want to upload the firmware, go to the binaries folder and follows the intructions given in the README file.
If you want to modify the firmware sources, go to the src folder and follows the instructions given in the README file.


Command List
--------------------------
### Principle
Basically, a command contains two fields, an integer which represents the kind of command, and a string containing all the required aguments
### Set pin mode
Configures the specified pin to behave either as an input or an output.

* **id** : 4
* **parameters** : pin mode
  * **pin** : the pin number
  * **mode** : in / input / out / output

*example : Set the pin 13 in output mode*

```
4 13 out 
```

### Digital write
Write a HIGH or a LOW value to a digital pin.

* **id** : 5
* **parameters** : pin value
  * **pin** : the pin number
  * **mode** : low / 0 / high / 1

*example : Write HIGH on the pin 13*

```
5 13 high 
```

### Digital read 
Read a HIGH or a LOW value from a digital pin.

* **id** : 6
* **parameters** : pin
  * **pin** : the pin number
* return : 6 pin value

*example : Read a high value on pin 13*

```
6 13 =>  6 13 1
```

Arduino Libraries
---------------------
The openplacos firmware for arduino use the following libraries

* CmdMessenger : http://arduino.cc/playground/Code/CmdMessenger
* RCSwitch : http://code.google.com/p/rc-switch/
* dht11 : http://arduino.cc/playground/Main/DHT11Lib

The libraries are packaged with the sources, you don't need to install them.
