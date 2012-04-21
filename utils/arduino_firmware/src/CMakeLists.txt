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

set(${FIRMWARE_NAME}_BOARD uno)               # Arduino Target board

set(${FIRMWARE_NAME}_PORT /dev/ttyACM0)            # Serial upload port


#====================================================================#
#  Target generation                                                 #
#====================================================================#
generate_arduino_firmware(${FIRMWARE_NAME})
