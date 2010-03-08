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

#include <avr/io.h>
#include <avr/interrupt.h>
#include "spi.h"



// Initialize the SPI Master interface
void SPI_MasterInit(void)
{
        /* Set MOSI and SCK output, all others input */
        DDRB = DDRB | ( (1<<DDB5) | (1<<DDB3) | (1<<DDB0) | (1<<DDB2)); 
        /* Enable SPI, Master, set clock rate fck/16 */
        SPCR = (1<<SPE)|(1<<MSTR)|(1<<SPR0);
        SPI_NoSlave();
}

// Transmit char over SPI
void SPI_MasterTransmit(char cData)
{
        /* Start transmission */
        SPDR = cData;
        /* Wait for transmission complete */
        while(!(SPSR & (1<<SPIF)));
}

// Recieve char over SPI
char SPI_MasterReceive(void)
{
        //send dummy char, to shift the SPDR
        SPI_MasterTransmit('@');
        
        /* Wait for reception complete */
        while(!(SPSR & (1<<SPIF)));
        
        

        /* Return data register */
        return SPDR;
}

// Select SPI slave to send data to
void SPI_SelectSlave(char slave){
       
     PORTB = PORTB & ~(1<<PORTB0);
       
}

// Disable chipselect on all SPI slaves (select no slave)
void SPI_NoSlave(void){
        /* Set SS high */       
        PORTB = PORTB | (1<<PORTB0);
}
