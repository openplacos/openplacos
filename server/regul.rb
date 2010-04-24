#!/usr/bin/env ruby

#    This file is part of Openplacos.
#
#    Openplacos is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    Openplacos is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with Openplacos.  If not, see <http://www.gnu.org/licenses/>.
#
# regul : set regulation


require 'top.rb'


class Regulation #simple regulation 

	def initialize(capteur_index,effecteur_index,seuil,hysteresis,refresh_rate)
		
		#definition des variable de classe
		
		@capteur_index= capteur_index
		@effecteur_index = effecteur_index
		@seuil = seuil.to_f
		@hysteresis = hysteresis.to_f
		@refresh_rate = refresh_rate
		
		#lancement du thread de régulation
		
		Thread.new do
			
			loop do
				
				valeur_capteur = $capteurs[@capteur_index].getValue
				etat_effecteur = $effecteurs[@effecteur_index].getValue
				
				if ((valeur_capteur!=nil) and (valeur_capteur >= (@seuil + @hysteresis/2)) and (etat_effecteur==false)) # si le seuil est dépassé par le haut et que l'effecteur n'est pas allumé
					$effecteurs[@effecteur_index].on
					puts "Allume l'effecteur n°" + @effecteur_index.to_s
				end
				
				if ((valeur_capteur!=nil) and (valeur_capteur <= (@seuil - @hysteresis/2)) and (etat_effecteur==true)) # si le seuil est dépassé par le bas et que l'effecteur est allumé
					$effecteurs[@effecteur_index].off
					puts "Etteind l'effecteur n°" + @effecteur_index.to_s
				end
				
				sleep(@refresh_rate)
			end
		end
		
	end 
		
end	
	
		
		


#truc plus générique
#affichage de la température

$mesure_temperature = Array.new

temps_regul = Regulation.new(0,0,27,1,1)

Thread.new do
i=0;
	loop do
		temp = $capteurs[0].getValue
		puts(temp)
		$mesure_temperature[i] = temp
		sleep(1.25)
		i=i+1
	end
end

sleep(2)
$effecteurs[1].on
sleep(120)


Gnuplot.open do |gp|
  Gnuplot::Plot.new( gp ) do |plot|
  
    plot.title  "Array Plot Example"
    plot.ylabel "x"
    plot.xlabel "x^2"
    N = $mesure_temperature.length
	y = $mesure_temperature
    x = (1..N).collect { |v| v.to_f }

    plot.data << Gnuplot::DataSet.new( [x, y] ) do |ds|
      ds.with = "linespoints"
      ds.notitle
    end
  end
end

$effecteurs[1].off
$effecteurs[0].off




