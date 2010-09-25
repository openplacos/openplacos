#!/usr/bin/env ruby
#
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
#
require 'libglade2'
require 'dbus'
require 'gtk2'
require 'ClassDef.rb'

class GuiGlade
  include GetText

  attr :glade
  
  def initialize(path_or_data, root = nil, domain = nil, localedir = nil, flag = GladeXML::FILE)
    bindtextdomain(domain, localedir, nil, "UTF-8")
    @glade = GladeXML.new(path_or_data, root, domain, localedir, flag) {|handler| method(handler)}
    @glade["main"].show_all
    @glade["main"].signal_connect('destroy') { Gtk.main_quit }
  end
  
  def on_connect_bt_clicked(widget)
    puts "Connexion with OpenplacOS server"
    @server = Server.new
    @monitor = Monitor.new(@glade['notebook'],@server.measures,@server.actuators,@server.config)
    @glade["main"].show_all
  end



end


# Main program
if __FILE__ == $0
  # Set values as your own application. 
  PROG_PATH = "GUI.glade"
  PROG_NAME = "YOUR_APPLICATION_NAME"
  gui = GuiGlade.new(PROG_PATH, nil, PROG_NAME)
  #server = Server.new
  Gtk.main
end
