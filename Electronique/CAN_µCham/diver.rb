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

puts "lecture CANCTRL can1 : " + affichage_reg(can1.send_READ(CANCTRL))

puts "lecture CANSTAT can1 : " + affichage_reg(can1.send_READ(CANSTAT))

puts "lecture CNF1 can1 : " + affichage_reg(can1.send_READ(CNF1))
puts "lecture CNF2 can1 : " + affichage_reg(can1.send_READ(CNF2))
puts "lecture CNF3 can1 : " + affichage_reg(can1.send_READ(CNF3))

puts "lecture TXRTSCTRL can1 : " + affichage_reg(can1.send_READ(TXRTSCTRL))

puts "lecture TEC can1 : " + affichage_reg(can1.send_READ(TEC))
puts "lecture REC can1 : " + affichage_reg(can1.send_READ(REC))

puts "lecture CANINTE can1 : " + affichage_reg(can1.send_READ(CANINTE))
puts "lecture CANINTF can1 : " + affichage_reg(can1.send_READ(CANINTF))

puts "lecture EFLG can1 : " + affichage_reg(can1.send_READ(EFLG))





can1.send_BIT_MOD(CNF1,"01000111".to_i(2),"11000111".to_i(2))
can1.send_BIT_MOD(CNF2,"11010000".to_i(2),"10010000".to_i(2))
can1.send_BIT_MOD(CNF3,"00000010".to_i(2),"00000010".to_i(2))

can1.send_BIT_MOD(CANCTRL,"11100000".to_i(2),"00000000".to_i(2))

read_config(can1)

can2.send_BIT_MOD(CNF1,"01000111".to_i(2),"11000111".to_i(2))
can2.send_BIT_MOD(CNF2,"11010000".to_i(2),"10010000".to_i(2))
can2.send_BIT_MOD(CNF3,"00000010".to_i(2),"00000010".to_i(2))


can2.send_BIT_MOD(CANCTRL,"11100000".to_i(2),"00000000".to_i(2))

read_config(can2)
