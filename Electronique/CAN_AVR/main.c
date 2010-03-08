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


#include "spi.h"
#include "mcp2515.h"
#include <stdio.h>
#include <avr/sleep.h>
#include <avr/interrupt.h>
#include <avr/io.h>

#define F_CPU 1000000UL  // 1 MHz

#include <util/delay.h>


//Initialize the CAN bus
void CAN_init(void){

        CAN_reset();

        uint8_t data[2];

        //Acceptance mask for RXB0 (all 11 bits counts)
        //dette filteret blokkerer alt?!?
        data[0] = 0b11111111;
        data[1] = 0b11100000;
        CAN_write(data[0], MASK_RXF0);
        CAN_write(data[1], MASK_RXF0+1);


        //RXF0
        //Receive filter 0 hits when id = 0x1F (exactly)        
        data[0] = 0b00000011;
        data[1] = 0b11100000;
        CAN_write(data[0], RXF0);
        CAN_write(data[1], RXF0+1);
        
        // Configuration des registre de timing
        
        CAN_write(0b00000000,CNF1);
        CAN_write(0b10010000,CNF2);
        CAN_write(0b00000010,CNF3);
  
		CAN_bit_modify(BFPCTRL, 0x0f, 0xff);
		CAN_bit_modify(CANCTRL, MASK_MODE, MODE_NORMAL); //set loopback mode
		
} 

void CAN_init_interrupt(void){

  // Set Pin 6 (PD2) as the pin to use for this example
  EIMSK |= (1<<INT0);

  // interrupt on INT0 pin falling edge (sensor triggered) 
  MCUCR = (0<<ISC01) | (0<<ISC00);

  sei();
}


SIGNAL (INT0_vect)
{ 		
		CAN_message message;
		CAN_read_rx(&message,0);
		
		if (bit_is_clear(PORTB, PORTB1)) {
			PORTB = PORTB | (1<<PORTB1);         
		} else {
			PORTB = PORTB & ~(1<<PORTB1);         
		}
}



int main (void)
{
	DDRB = DDRB | (1<<DDB1);
	
	SPI_MasterInit();
	CAN_init();
	CAN_init_interrupt();
	
    for (;;)                    /* Note [7] */
        sleep_mode();

    return (0);

	
	/*while (1) {
		_delay_ms(1000);	
		PORTB = PORTB | (1<<PORTB1);         
		_delay_ms(1000);	
		PORTB = PORTB & ~(1<<PORTB1);         
	}
    return (0);*/
}
 

