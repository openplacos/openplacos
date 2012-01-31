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

require 'Pin.rb'

class Export
    attr_reader :pin_output, :path_dbus

  def initialize(config_)
    @config     = config_
    @path_dbus  = @config
    @pin_output = Pin_export.new(config_)
  end

  def expose_on_web
    dis = Dispatcher.instance
    pin_plugs = dis.get_plug(@path_dbus)    
    
    #generate uri for object
    #generate a json string with name and ifaces
    outHash = Hash.new
    outHash["name"] = @path_dbus
    outHash["interfaces"] = Array.new
    pin_plugs.each do |pin|
      outHash["interfaces"] << pin.config.keys # get the ifaces and push it in the hash
    end
    outHash["interfaces"].flatten!
    WebServer.instance_eval( "get('#{@path_dbus}') {'#{outHash.to_json}'}")
    
    # generate uri and responce for iface
    pin_plugs.each do |pin|
      outHash = Hash.new
      outHash["name"] = @path_dbus
      pin.config.each do |iface, meths|
        outHashbis = outHash.dup
        outHashbis["interface"] = iface.to_s
        if meths.include?("read") # read correspond to get
          WebServer.instance_eval( "get('#{@path_dbus}/#{iface.to_s}') { #{outHashbis.inspect}.merge({'value' => Dispatcher.instance.call('#{@path_dbus}','#{iface}','read',{})[0]}).to_json }")
        end
      end

    end
  end
end
