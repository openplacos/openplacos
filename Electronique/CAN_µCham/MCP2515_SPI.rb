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

require 'rubygems'

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

class MCP2515



	def initialize(cs,sp)
		@cs = cs.to_s
		@sp = sp
	
		sp.write "pin " + cs.to_s + " out\n" # active le mode sortie sur CS
		send_RESET
	end

	def cs
		@cs
	end
	
	def sp
		@sp
	end
	

	#intruction RX_STATUS
	def send_RX_STATUS

		@sp.write "pin " + @cs + " 0\n"
		
		@sp.write  "spi out 176\n"
		
		@sp.write  "spi in\n"
		retour = @sp.gets
		retour = retour[7..retour.length].to_i
		
		@sp.write  "spi in\n"
		retour = @sp.gets
		retour = retour[7..retour.length].to_i
		
		@sp.write "pin " + @cs + " 1\n"
		
		return retour
	end

	def send_READ_STATUS
		
		@sp.write "pin " + @cs + " 0\n"
		
		@sp.write  "spi out 160\n"
		
		@sp.write  "spi in\n"
		retour = @sp.gets
		retour = retour[7..retour.length].to_i
		
		@sp.write "pin " + @cs + " 1\n"
		return retour
	end

	def send_RESET

		@sp.write "pin " + @cs + " 0\n"
		
		@sp.write  "spi out " + ("11000000".to_i(2)).to_s + "\n"
		
		@sp.write "pin " + @cs + " 1\n"
	end

	def send_READ(adresse)

		@sp.write "pin " + @cs + " 0\n"
		
		@sp.write  "spi out 3\n"
		@sp.write  "spi out " + adresse.to_s + "\n"
		@sp.write  "spi in\n"
		retour = @sp.gets
		retour = retour[7..retour.length].to_i
				
		@sp.write "pin " + @cs + " 1\n"
		return retour
	end

	def send_WRITE(adresse,data)

		@sp.write "pin " + @cs + " 0\n"
		
		@sp.write  "spi out 2\n"
		@sp.write  "spi out " + adresse.to_s + "\n"
		@sp.write  "spi out " + data.to_s + "\n"
		
		
		@sp.write "pin " + @cs + " 1\n"
	end

	def send_READ_RX(n,m)

		@sp.write "pin " + @cs + " 0\n"
		
		@sp.write  "spi out " + ("10010" + n.to_s + m.to_s + "0").to_i(2).to_s +  "\n"
		
		if m==0
			nb = 13
		else
			nb = 8
		end
		retour = Array.new(nb)
		i=0
		nb.times{
			@sp.write  "spi in\n"
			temp = @sp.gets
			retour[i] = temp[7..temp.length].to_i
			i +=1
		}
		
		@sp.write "pin " + @cs + " 1\n"
		return retour
	end

	def send_LOAD_TX(a,b,c,data) # a debugger

		@sp.write "pin " + @cs + " 0\n"
		
		@sp.write  "spi out " + ("01000" + a.to_s + b.to_s + c.to_s).to_i(2).to_s +  "\n"
		@sp.write  "spi out " + data.to_s + "\n"
		
		@sp.write "pin " + @cs + " 1\n"
		
	end

	def send_RTS(t2,t1,t0)

		@sp.write "pin " + @cs + " 0\n"
		
		@sp.write  "spi out " + ("10000" + t2.to_s + t1.to_s + t0.to_s).to_i(2).to_s +  "\n"
		
		@sp.write "pin " + @cs + " 1\n"
		
	end

	def send_BIT_MOD(adresse,mask,data)

		@sp.write "pin " + @cs + " 0\n"
		
		@sp.write  "spi out " + "00000101".to_i(2).to_s + "\n"
		@sp.write  "spi out " + adresse.to_s + "\n"
		@sp.write  "spi out " + mask.to_s + "\n"
		@sp.write  "spi out " + data.to_s + "\n"
		
		@sp.write "pin " + @cs + " 1\n"
	end
	
	def filter_READ(n_filter)
		if n_filter < 3
			start_adresse = 4*n_filter
		else 
			start_adresse = 16 + (4-4)*n_filter
		end
		i = 0
		retour = Array.new(4)
		4.times{
			retour[i] = send_READ(start_adresse + i)		
			i += 1
		}
		return retour
	end
	
	def mask_READ(n_mask)
		
		start_adresse = 32 + 4*n_mask
		
		i = 0
		retour = Array.new(4)
		4.times{
			retour[i] = send_READ(start_adresse + i)		
			i += 1
		}
		return retour
	end
	
	def filter_is_standardID(n_filter)
		
		if n_filter < 3
			start_adresse = 4*n_filter + 1
		else 
			start_adresse = 17 + (4-4)*n_filter
		end
		
		retour = send_READ(start_adresse).to_s(2)
		retour = "0"*(8 - retour.length) +  retour
		return retour[4..4]
	
	end
	
	
	def mask_is_standardID(n_mask)
		
		start_adresse = 33 + 4*n_mask
		
		retour = send_READ(start_adresse).to_s(2)
		retour = "0"*(8 - retour.length) +  retour
		return retour[4..4]
	
	end
	
	
	def filter_WRITE(n_filter,filter)
		if n_filter < 3
			start_adresse = 4*n_filter
		else 
			start_adresse = 16 + (4-4)*n_filter
		end
		
		if filter < 2048
			id = "0"*(11 - filter.to_s(2).length) + filter.to_s(2)
			send_WRITE(start_adresse,id[0..7].to_i(2))
			send_WRITE(start_adresse+1,(id[8..11] + "00000").to_i(2))
			send_WRITE(start_adresse+2,0)
			send_WRITE(start_adresse+3,0)
		else
		
		end
				
	end
		
		
	def mask_WRITE(n_mask,mask)
		
		start_adresse = 32 + 4*n_mask
		
		if mask < 2048
			id = "0"*(11 - mask.to_s(2).length) + mask.to_s(2)
			send_WRITE(start_adresse,id[0..7].to_i(2))
			send_WRITE(start_adresse+1,(id[8..11] + "00000").to_i(2))
			send_WRITE(start_adresse+2,0)
			send_WRITE(start_adresse+3,0)
		else
		
		end
				
	end	
	
	def transmit_buffer_READ(n_buffer)
		
		start_adresse = 48 + 1 + 16*n_buffer
		
		i = 0
		retour = Array.new(13)
		13.times{
			retour[i] = send_READ(start_adresse + i)		
			i += 1
		}
		return retour
	end
	
	def receive_buffer_READ(n_buffer)
		
		start_adresse = 96 + 1 + 16*n_buffer
		
		i = 0
		retour = Array.new(13)
		13.times{
			retour[i] = send_READ(start_adresse + i)		
			i += 1
		}
		return retour
	end
	
	def transmit_buffer_WRITE_ID(n_buffer,dest_id)
		
		start_adresse = 48 + 1 + 16*n_buffer
		
		if dest_id < 2048
			id = "0"*(11 - dest_id.to_s(2).length) + dest_id.to_s(2)
			send_WRITE(start_adresse,id[0..7].to_i(2))
			send_WRITE(start_adresse+1,(id[8..11] + "00000").to_i(2))
			send_WRITE(start_adresse+2,0)
			send_WRITE(start_adresse+3,0)
		else
		
		end
				
	end	
	
	def transmit_buffer_WRITE_DATA(n_buffer,data)
		
		start_adresse = 48 + 6 + 16*n_buffer
		
		i=0
		data.length.times{
			send_WRITE(start_adresse + i, data[i])
			i += 1
		}
				
	end	
		
		
end
