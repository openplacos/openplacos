#=============================================================================#
# Author: Miaoufkirsh                                                         #
# Date:   18.04.2012                                                          #
#                                                                             #
# Description: arduino firwmare for openplacos                                #
#                                                                             #
#=============================================================================#


#====================================================================#
#  Settings                                                          #
#====================================================================#
set(CMAKE_TOOLCHAIN_FILE ${CMAKE_SOURCE_DIR}/cmake/ArduinoToolchain.cmake) # Arduino Toolchain

cmake_minimum_required(VERSION 2.8)

set(FIRMWARE_NAME arduinoDAC)

project(arduinoDAC C CXX)

set(${FIRMWARE_NAME}_SKETCH  ${CMAKE_SOURCE_DIR}/arduinoDAC) # Path to sketch directory

link_directories(${CMAKE_SOURCE_DIR}/arduinoDAC/libraries)

set(ARDUINO_DEFAULT_BOARD uno) # Default Board ID, when not specified
set(ARDUINO_DEFAULT_PORT /dev/ttyACM0) # Default Port, when not specified


#====================================================================#
#  Target generation                                                 #
#====================================================================#
#generate_arduino_firmware(${FIRMWARE_NAME})
generate_arduino_firmware(Uno
  SKETCH ${CMAKE_SOURCE_DIR}/arduinoDAC 
  BOARD uno
  PORT /dev/ttyACM0)
  
generate_arduino_firmware(MEGA1280
  SKETCH ${CMAKE_SOURCE_DIR}/arduinoDAC 
  BOARD mega
  PORT /dev/ttyUSB0)

generate_arduino_firmware(MEGA2560
  SKETCH ${CMAKE_SOURCE_DIR}/arduinoDAC 
  BOARD mega2560
  PORT /dev/ttyUSB0)  

