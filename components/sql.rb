#!/usr/bin/ruby -w
# -*- coding: utf-8 -*-
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

require "rubygems"
require 'active_record' 
require "logger"
require "/home/flagos/projects/openplacos/gem/lib/openplacos/libclient.rb"

require File.dirname(__FILE__) << "/LibComponent.rb"

component = LibComponent::Component.new(ARGV) do |c|
  c.description  "OpenplacOS driver for µChameleon board"
  c.default_name "uchameleon"
  c.option :database, "Database name", :default => "openplacos"
  c.option :username, "DB user",       :default => "openplacos"
  c.option :password, "DB password",   :default => "opospass"
  c.option :adapter, "DB adapter",     :default => "mysql"
end

options = { 
  "adapter"  => component.options[:adapter],
  "encoding" => "utf8",
  "database" => component.options[:database],
  "username" => component.options[:username],
  "password" => component.options[:password]
}

client = Openplacos::Client.new

ActiveRecord::Base.default_timezone = :utc

ActiveRecord::Base.establish_connection( options )
ActiveRecord::Base.logger = Logger.new(STDOUT)

Dir.chdir(  File.expand_path(File.dirname(__FILE__) + "/"))

ActiveRecord::Migrator.migrate('db/migrate')


class User < ActiveRecord::Base
  has_many :flows
end
class Card < ActiveRecord::Base
  has_many :devices
end
class Device < ActiveRecord::Base 
  belongs_to :card
  has_one    :sensor
  has_one    :actuator
end
class Sensor < ActiveRecord::Base
  belongs_to :device
  has_many   :measures
end
class Actuator < ActiveRecord::Base 
  belongs_to :device
  has_many   :instructions
end
class Flow < ActiveRecord::Base
  belongs_to :user
  has_many   :measures
  has_many   :instructions
end
class Measure < ActiveRecord::Base
  belongs_to :flow
  belongs_to :sensor
end
class Instruction < ActiveRecord::Base
  belongs_to :flow
  belongs_to :actuator 
end

puts "OK"

client.get_sensors.each { |key, obj|
  if (key != "/informations")

    puts Device.joins(:sensor).exists?(:config_name => key)
      
    obj.each { |iface|
      puts key + ": "+iface.read({})[0].to_s + " #{key.split('.').last}"
    }
  end
}

Process.exit 0

puts "Done with sensors"

client.get_objects.each_pair{ |key, obj|
  if (key != "/informations")
    puts key 
    obj.interfaces.each { |iface|
      puts iface + ": "+obj[iface].read({})[0].to_s 
    }
  end
}
Process.exit 0



plugin.opos.on_signal("create_measure") do |name,config|
  MUT.synchronize{
    if !Device.exists?(:config_name => config["path"])
      dev = Device.create(:config_name => config["path"],
                          :model => config["model"],
                          :path_dbus => config["path"])
                          #:card_id => Card.find(:first, :conditions => [ "config_name = ?",  meas.instance_variable_get(:@card_name)]))
                          
      Sensor.create(:device_id => dev.id, :unit => config["informations"]['unit'])
    end
  }
end

plugin.opos.on_signal("create_actuator") do |name,config|
  MUT.synchronize{
    if !Device.exists?(:config_name => config["path"])
      dev = Device.create(:config_name => config["path"],
                          :model => config["model"],
                          :path_dbus => config["path"])
                          #:card_id => Card.find(:first, :conditions => [ "config_name = ?", act.instance_variable_get(:@card_name)])) 
      Actuator.create(:device_id => dev.id, :interface => config["driver"]["interface"]) 
    end
  }
end

plugin.opos.on_signal("new_measure") do |name, value, option|
  MUT.synchronize{
    time = Time.new.utc  
    flow = Flow.create(:date  => time ,:value => value) 
    device =  Device.find(:first, :conditions => { :config_name => name })
    sensor =  Sensor.find(:first, :conditions => { :device_id => device.id })
    Measure.create(:flow_id => flow.id,:sensor_id => sensor.id) 
  }
end

plugin.opos.on_signal("new_order") do |name, order, option|
  MUT.synchronize{
    flow = Flow.create(:date  => Time.new.utc ,:value => order) 
    device =  Device.find(:first, :conditions => { :config_name => name })
    actuator = Actuator.find(:first, :conditions => { :device_id => device.id })
    Instruction.create(:flow_id => flow.id,:actuator_id => actuator.id)
  }
end

plugin.opos.on_signal("create_card") do |name,config|
  MUT.synchronize{
    if !Card.exists?(:config_name => name)
      Card.create(:config_name => name, :path_dbus => name ) # model, usb id missing
    end
  }
end

plugin.run
