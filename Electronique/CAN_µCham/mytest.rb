# 	This file is part of Openplacos.
#
#   Openplacos is free software: you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation, either version 3 of the License, or
#   (at your option) any later version.
#
#   Openplacos is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with Openplacos.  If not, see <http://www.gnu.org/licenses/>.


require 'MCP2515_SPI.rb'
require 'uCham.rb'

def affichage_reg(reg)
	chaine = "0"*(8-reg.to_s(2).length) + reg.to_s(2)
	return chaine
end

def read_config(can)
	puts "----------- Start Read Config ----------------------------"
	puts "lecture CANCTRL can1 : " + affichage_reg(can.send_READ(CANCTRL))

	puts "lecture CANSTAT can1 : " + affichage_reg(can.send_READ(CANSTAT))

	puts "lecture CNF1 can1 : " + affichage_reg(can.send_READ(CNF1))
	puts "lecture CNF2 can1 : " + affichage_reg(can.send_READ(CNF2))
	puts "lecture CNF3 can1 : " + affichage_reg(can.send_READ(CNF3))
	puts "----------- End Read Config----------------------------"

end

CANCTRL = "1111".to_i(2)
CANSTAT = "1110".to_i(2)

CNF1 = "00101010".to_i(2)
CNF2 = "00101001".to_i(2)
CNF3 = "00101000".to_i(2)

TXRTSCTRL = "1101".to_i(2)
BFPCTRL = "1100".to_i(2)

TEC = "11100".to_i(2)
REC = "11101".to_i(2)

CANINTE = "101011".to_i(2)
CANINTF = "101100".to_i(2)

EFLG = "101101".to_i(2)

TXB0CTRL = "110000".to_i(2)
TXB1CTRL = "1000000".to_i(2)
TXB2CTRL = "1010000".to_i(2)
RXB0CTRL = "1100000".to_i(2)
RXB1CTRL = "1110000".to_i(2)

TXB0DLC = "110101".to_i(2)
TXB1DLC = "1000101".to_i(2)
TXB2DLC = "1010101".to_i(2)
RXB0DLC = "1100101".to_i(2)
RXB1DLC = "1110101".to_i(2)

# parametre µCham
USB = "/dev/ttyUSB0" # Nom du µChameleon

sp = uCham_open(USB)
spi_initialise(sp)

can1 = MCP2515.new(1,sp)
can2 = MCP2515.new(2,sp)


can1.send_WRITE(CNF1,"00000000".to_i(2))
can1.send_WRITE(CNF2,"10010000".to_i(2))
can1.send_WRITE(CNF3,"00000010".to_i(2))

can1.send_BIT_MOD(CANCTRL,"11100100".to_i(2),"00000000".to_i(2))

#read_config(can1)

can2.send_WRITE(CNF1,"00000000".to_i(2))
can2.send_WRITE(CNF2,"10010000".to_i(2))
can2.send_WRITE(CNF3,"00000010".to_i(2))

can2.mask_WRITE(0,2047)
can2.mask_WRITE(1,2047)
can2.filter_WRITE(0,2000)


can2.send_BIT_MOD(CANCTRL,"11100100".to_i(2),"00000000".to_i(2))

#read_config(can2)

can1.transmit_buffer_WRITE_ID(0,2000)
can1.send_WRITE(TXB0DLC,"00001000".to_i(2))
data = Array.new(8){rand(255)}

can1.transmit_buffer_WRITE_DATA(0,data)
puts can1.transmit_buffer_READ(0)


can1.send_RTS(0,0,1)
sleep 0.125

puts "lecture TEC can1 : " + affichage_reg(can1.send_READ(TEC))
puts "lecture REC can2 : " + affichage_reg(can2.send_READ(REC))

puts "lecture TXB0CTRL can1 : " + affichage_reg(can1.send_READ(TXB0CTRL))

puts "lecture RXB0CTRL can2 : " + affichage_reg(can2.send_READ(RXB0CTRL))

puts can2.send_READ_RX(0,0)

uCham_close(sp)


