#!/bin/sh

#install dependencies :
echo "------------------------------"
echo "    packaged dependencies     "
echo "------------------------------"

apt-get install gcc-avr binutils-avr avr-libc avrdude cmake

echo "------------------------------"
echo "         arduino SDK          "
echo "------------------------------"

cd /usr/share

if [ ! -d "/usr/share/arduino" ]
then
  echo "install arduino SDK !" 
  wget http://arduino.googlecode.com/files/arduino-1.0-linux.tgz

  tar -xvf arduino-1.0-linux.tgz
  
  mv arduino-1.0 arduino
  
  rm arduino-1.0-linux.tgz
else
  echo "Arduino SDK already installed !"
fi
