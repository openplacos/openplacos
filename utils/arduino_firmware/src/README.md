ArduinoDAC firmware
---------------------------
This folder contains the sources of the arduinoDAC firmware for openplacos.
We use CMake-arduino for the build process : https://github.com/queezythegreat/arduino-cmake 

Do not use the arduino IDE, it will be unable to find the librairies.

Dependencies
--------------------------
* cmake
* gcc-avr
* binutils-avr 
* avr-libc 
* avrdude
* arduino SDK

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
4,13 out 
```

### digital write
Write a HIGH or a LOW value to a digital pin.

* **id** : 5
* **parameters** : pin value
  * **pin** : the pin number
  * **value** : low / 0 / high / 1

*example : Write High to the digital pin 13*

```
5,13 high
```

Usage
---------------------------
* Install dependencies :
  
    sudo ./dependencies.sh

* to build :

    ./build.sh

* to build and upload :

    ./build_and_upload.sh
    
