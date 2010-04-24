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
# top : configure ressources


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
		@value = nil
		
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
		if @value==nil
			return false # return false par defaut ( peut pas verifier car pas acces a la methode pour le faire)
		else
			return @value
		end
	end
	
end

class Capteur < Ressource
	
	def getValue
		@value = (@method.call)[0]
		return @value
	end

end



#Configuration 

# Lis le fichier config.xml
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


