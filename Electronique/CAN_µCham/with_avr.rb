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
	puts "lecture CANCTRL can : " + affichage_reg(can.send_READ(CANCTRL))

	puts "lecture CANSTAT can : " + affichage_reg(can.send_READ(CANSTAT))

	puts "lecture CNF1 can : " + affichage_reg(can.send_READ(CNF1))
	puts "lecture CNF2 can : " + affichage_reg(can.send_READ(CNF2))
	puts "lecture CNF3 can : " + affichage_reg(can.send_READ(CNF3))
	puts "----------- End Read Config----------------------------"

end


# parametre µCham
USB = "/dev/ttyUSB0" # Nom du µChameleon

sp = uCham_open(USB)
spi_initialise(sp)

can1 = MCP2515.new(1,sp)



can1.send_WRITE(CNF1,"00000000".to_i(2))
can1.send_WRITE(CNF2,"10010000".to_i(2))
can1.send_WRITE(CNF3,"00000010".to_i(2))

can1.send_BIT_MOD(TXRTSCTRL,"00000001".to_i(2),"00000001".to_i(2))

can1.send_BIT_MOD(CANCTRL,"11100100".to_i(2),"00000000".to_i(2))

#read_config(can1)



#read_config(can2)

can1.transmit_buffer_WRITE_ID(0,31)
can1.send_WRITE(TXB0DLC,"00001000".to_i(2))
data = Array.new(8){rand(255)}

#can1.transmit_buffer_WRITE_DATA(0,data)

10.times{
	can1.send_RTS(0,0,1)
	puts "message envoyé"
	sleep 0.1
	}
puts "lecture TEC can1 : " + affichage_reg(can1.send_READ(TEC))

puts "lecture TXB0CTRL can1 : " + affichage_reg(can1.send_READ(TXB0CTRL))


uCham_close(sp)



