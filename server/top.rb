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
# top : lauch driver and configure ressources


require 'rubygems'
require 'gnuplot'
require 'dbus'
require 'rexml/document'
# Ressource object
# une ressource est un capteur ou un effecteur

class Ressource 

	def initialize(driver,object,interface,method)
		bus = DBus::SessionBus.instance
		@driver = bus.service(driver)
		@object = @driver.object(object)
		@object.introspect
		@interface = @object[interface]
		@method = @interface.method(method)
		
	end
	

end


class Effecteur < Ressource

	def on
		@method.call(true)
		@value = true
	end
	
	def off
		@method.call(false)
		@value = false
	end
	
	def getValue
		[@value]
	end
	
end

class Capteur < Ressource
	
	def getValue
		@value = @method.call
		[@value]
	end

end



#Configuration 
#On par du principe que l'utilisateur a l'etape de configuration fourni ces informations

#DRIVER = "org.openplacos.drivers.uChameleon"
#OBJECT = "/pin_14"
#INTERFACE = "org.openplacos.driver.uChamInterface"
#METHODE = "Write_b"

## on creer ensuite une objet Ressource completement générique avec des méthodes la aussi génériques 
## on a donc une ressoure auquelle on peut acceder avec une abstraction complete vis a vis du matos
## a priori cette ressource est publique et les methodes sont accessibles par d'autre truc générique style régulation
## les methodes générique sont a définir
## il faudra surement definir deux objet , mesure et effecteur qui erritent de ressoure car certaines methodes sont spécifique au capteurs et d'autres aux mesures


##bon la c plus générique vue que c pour l'exemple

#led = Effecteur.new(DRIVER,OBJECT,INTERFACE,METHODE)
#capteur = Capteur.new(DRIVER,"/pin_2",INTERFACE,"Read_analog")

#loop do 
	#temperature = (capteur.getValue[0][0].to_f)*4.58
	#puts "La temprérature est de " + ((temperature-2.73)*100).to_s[0..3] + "°C"
	#led.on
	#sleep(10)
	#led.off
	#sleep(10)
#end



include REXML
doc = Document.new(File.new("config.xml"))

#creation des objet capteurs
$capteurs = Array.new

doc.root.elements['List_of_capteur'].each_element{ |capteur|
	
	ressource = doc.root.elements['List_of_ressources'].elements["Ressource[@name='" + capteur.elements['ressource'].text + "']"]
	$capteurs[$capteurs.length] = Capteur.new(ressource.elements['driver'].text,ressource.elements['object'].text,ressource.elements['interface'].text,ressource.elements['method'].text)
}

#creation des objet effecteurs
$effecteurs = Array.new

doc.root.elements['List_of_effecteur'].each_element{ |capteur|
	
	ressource = doc.root.elements['List_of_ressources'].elements["Ressource[@name='" + capteur.elements['ressource'].text + "']"]
	$effecteurs[$effecteurs.length] = Effecteur.new(ressource.elements['driver'].text,ressource.elements['object'].text,ressource.elements['interface'].text,ressource.elements['method'].text)
}


#truc plus générique
#affichage de la température

$mesure_temperature = Array.new
$mesure_eclairage = Array.new
$mesure_ventilation = Array.new

Thread.new do
i=0;
	loop do
		$mesure_temperature[i] = $capteurs[0].getValue
		sleep(0.25)
		i=i+1
	end
end

sleep(2)
$effecteurs[1].on
sleep(60)
$effecteurs[0].on
sleep(60)
$effecteurs[1].off
$effecteurs[0].off

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



