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

#include "mcp2515.h"
#include "spi.h"

// Reset the CAN chip
void CAN_reset(void){
        SPI_SelectSlave(SPI_CAN);
        SPI_MasterTransmit(INS_RESET);
        SPI_NoSlave();
}

// Read
void CAN_read(char* data, uint8_t address , int data_count){
        int i;
        SPI_SelectSlave(SPI_CAN);       

        SPI_MasterTransmit(INS_READ);
        SPI_MasterTransmit((char)address);
        for(i = 0; i < data_count; i++){
                data[i] = SPI_MasterReceive();
        }

        SPI_NoSlave();

}

void CAN_read_rx(CAN_message* msg, uint8_t rx){
        int i;
        if (rx>1)
                return;
        if(rx == 0) rx = 1; //decode rx0 to word for "read from rxb0", standard frame
        else if(rx == 1) rx = 3; //decode rx1 to intruction for "read from rxb1", standard frame
        
        SPI_SelectSlave(SPI_CAN);       
        SPI_MasterTransmit(INS_READ_RX | (rx<<1));
        for (i = 0; i < 8; i++){
                msg->data[i] = SPI_MasterReceive();
        }
        
        SPI_NoSlave();
}

void CAN_write(char data, uint8_t address){
        SPI_SelectSlave(SPI_CAN);       

        SPI_MasterTransmit(INS_WRITE);
        SPI_MasterTransmit((char)address);
        SPI_MasterTransmit(data);

        SPI_NoSlave();

}
//tx = "modul" (3 output "kanaler")
void CAN_load_tx(char* msg, uint8_t tx){
        int i;
        if (tx>2)
                return;
        tx = (tx+1)*2 - 1; //convert to abc-format as explained in table 12-5
        SPI_SelectSlave(SPI_CAN);
        
        SPI_MasterTransmit(INS_LOAD_TX | tx);
        for(i = 0; i < 8; i++){
                SPI_MasterTransmit(msg[i]);
        }

        SPI_NoSlave();
}

void CAN_rts(uint8_t tx){
        if (tx == 0) tx = 1;
        else if (tx == 1) tx = 2;
        else if (tx == 2) tx = 4;
        else return;
        
        SPI_SelectSlave(SPI_CAN);
        SPI_MasterTransmit(INS_RTS | tx);

        SPI_NoSlave();
}

uint8_t CAN_read_status(void){
        char status;
        SPI_SelectSlave(SPI_CAN);

        SPI_MasterTransmit(INS_READ_STATUS);
        status = SPI_MasterReceive();

        SPI_NoSlave();
        
        return (uint8_t) status;

}

uint8_t CAN_rx_status(void){
return 0;

}
void CAN_bit_modify(uint8_t address, uint8_t mask, uint8_t data){
        SPI_SelectSlave(SPI_CAN);


        SPI_MasterTransmit((char)INS_BIT_MODIFY);       
        SPI_MasterTransmit((char)address);
        SPI_MasterTransmit((char)mask);
        SPI_MasterTransmit((char)data);

        SPI_NoSlave();
}
