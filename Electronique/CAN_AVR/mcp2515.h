/*  This file is part of Openplacos.

    Openplacos is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    Foobar is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with Foobar.  If not, see <http://www.gnu.org/licenses/>.
*/

#ifndef _MCP2515_H
#define _MCP2515_H

#include <avr/io.h>

#define OUR_ADDRESS             15

#define INS_RESET               0b11000000
#define INS_READ                0b00000011
#define INS_READ_RX             0b10010000 //10010nm0
#define INS_WRITE               0b00000010
#define INS_LOAD_TX             0b01000000 //01000abc
#define INS_RTS                 0b10000000 //10000nnn
#define INS_READ_STATUS 0b10100000
#define INS_RX_STATUS   0b10110000
#define INS_BIT_MODIFY  0b00000101


#define MODE_NORMAL             0b00000000      
#define MODE_SLEEP              0b00100000                      
#define MODE_LOOPBACK   0b01000000
#define MODE_LISTEN             0b01100000
#define MODE_CONFIG             0b10000000

#define ID_TYPE_NONE            0b01100000 //no ID type filter (all messages accepted)
#define ID_TYPE_STANDARD        0b00100000 //receive only messages with standard ID
#define ID_TYPE_EXTENDED        0b01000000 //receive only messages with extended ID
#define ID_TYPE_BOTH            0b00000000 //receive messages with both types of ID

#define MASK_MODE                               0b11100000
#define MASK_DLC                                0b00001111 //mask for data length in TXn control register
#define MASK_SIDL                               0b11100000 //mask for bits in id low register
#define MASK_TXREQ0                             0b00000100 //transmit request: 1 for unsent message
#define MASK_CANINTF_RX0IF              0b00000001 //data received in receive buffer 0
#define MASK_RECEIVE_ID_TYPE    0b01100000 //
#define MASK_B0BFE                              0b00000100 //Bit Function Enable (to enable buffer full interrupt on output pin)
#define MASK_B0BFM                              0b00000001 //Bit Function Mode (1 in this bit sets the Bit Function Mode to interrupt)

#define CANCTRL                 0x0F       //control register for CAN

#define TXB0CTRL              0b00110000 //control register for TX0
#define TXB0SIDH                0b00110001 //transmit buffer 0 standard identifier high
#define TXB0SIDL                0b00110010 //transmit buffer 0 standard identifier low
#define TXB0DLC                 0b00110101 //transmit buffer 0 data length code
#define TXB0D0                  0b00110110 //data byte 0 for TX0
#define RXB0D0                  0b01100110 //data byte 0 for RX0
#define RXB1D0                  0b01110110 //data byte 0 for RX1
#define BFPCTRL                 0b00001100 //BFPCTRL

#define RXB0CTRL                0b01100000 //Receive buffer 0 control register


#define RXF0                    0b00000000 //Receive filter addresses
#define RXF1                    0b00000100
#define RXF2                    0b00001000
#define RXF3                    0b00010000
#define RXF4                    0b00010100
#define RXF5                    0b00011000

#define MASK_RXF0               0b00100000 //Receive mask addresses
#define MASK_RXF1               0b00100100


#define CNF1		0b00101010
#define CNF2		0b00101001
#define CNF3		0b00101000


//MASK_RECEIVE_FILTER, MODE_NO_FILTER)

typedef struct {
        unsigned int id;
        uint8_t length;
        char *data;
} CAN_message;



void CAN_reset(void);
void CAN_read(char* data, uint8_t address , int data_count);
void CAN_read_rx(CAN_message*, uint8_t);
void CAN_write(char, uint8_t);
void CAN_load_tx(char*, uint8_t);
void CAN_rts(uint8_t);
uint8_t CAN_read_status(void);
uint8_t CAN_rx_status(void);
void CAN_bit_modify(uint8_t address, uint8_t mask, uint8_t data);




#endif //_MCP2515_H
