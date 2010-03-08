# This file is part of Openplacos.
#
#   Openplacos is free software: you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation, either version 3 of the License, or
#   (at your option) any later version.
#
#   Foobar is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with Foobar.  If not, see <http://www.gnu.org/licenses/>.


require 'serialport'



# fonction 
def uCham_open(uCham)
	sp = SerialPort.new uCham
	puts "Ouverture de la connexion au µChameleon"
	return sp
end

def uCham_close(sp)
	sp.close
	puts "Fermeture de la connexion au µChameleon"
end


# initialisation du spi
def spi_initialise(sp)

	sp.write "spi on\n" # active le spi

	sp.write "spi pre 32\n" # Regle la frequence d'horloge

	puts "spi initialisé"
end
