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

Usage
---------------------------
* Install dependencies :
  
    sudo ./dependencies.sh

* to build :

    ./build.sh

* to build and upload :

    ./build_and_upload.sh
    
