#!/usr/bin/ruby -w

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
require "openplacos"
require "micro-optparse"

options = Parser.new(ARGV) do |p|
  p.banner = "This is openplacos plugins for sql database"
  p.version = "sql 1.0"
  p.option :database, "the name of the database", :default => "openplacos"
  p.option :username, "the name of the user", :default => "openplacos"
  p.option :password, "the password", :default => "opospass"
end.process!


plugin = Openplacos::Plugin.new

options = { "adapter" => "mysql2",
            "encoding" => "utf8",
            "database" => options[:database],
            "username" => options[:username],
            "password" => options[:password]}

ActiveRecord::Base.establish_connection( options )

ActiveRecord::Schema.define do
  if !ActiveRecord::Base.connection.table_exists?('users')
    create_table :users do |table|
      table.column :login, :string, :limit => 80, :null => false
      table.column :first_name, :string, :limit => 80
      table.column :last_name, :string, :limit => 80
      table.column :email, :string, :limit => 80
    end
  end
  
  if !ActiveRecord::Base.connection.table_exists?('cards')
    create_table :cards do |table|
      table.column :config_name, :string, :limit => 80
      table.column :model, :string, :limit => 80
      table.column :usb_id, :integer
      table.column :path_dbus, :string
    end
  end

  if !ActiveRecord::Base.connection.table_exists?('devices')
    create_table :devices do |table|
      table.column :config_name, :string, :limit => 80
      table.column :model, :string, :limit => 80
      table.column :path_dbus, :string
      table.references(:card) 
    end
  end

  if !ActiveRecord::Base.connection.table_exists?('sensors')
    create_table :sensors do |table|
      table.column :unit, :string, :limit => 80
      table.references(:device) 
    end    
  end

  if !ActiveRecord::Base.connection.table_exists?('actuators')
    create_table :actuators do |table|
      table.column :interface, :string, :limit => 80
      table.references(:device) 
    end            
  end

  if !ActiveRecord::Base.connection.table_exists?('flows')
    create_table :flows do |table|
      table.column :date, :datetime 
      table.column :value, :float, :null => false
      table.references(:user) 
    end   
  end
  
  if !ActiveRecord::Base.connection.table_exists?('measures')
    create_table :measures do |table|
      table.references(:flow, :sensor) 
    end
  end    

  if !ActiveRecord::Base.connection.table_exists?('instructions')
    create_table :instructions do |table|
      table.references(:flow, :actuator) 
    end
  end          
end




class User < ActiveRecord::Base
  #has_many :flows
end
class Card < ActiveRecord::Base
  #has_many :devices
end
class Device < ActiveRecord::Base 
  #belongs_to :card
  #has_many :sensors
  #has_many :actuators
end
class Sensor < ActiveRecord::Base
  #belongs_to :device
  #has_many :measures
end
class Actuator < ActiveRecord::Base 
  #belongs_to :device
  #has_many :instructions
end
class Flow < ActiveRecord::Base
  #belongs_to :user
  #has_many :measures
  #has_many :instructions
end
class Measure < ActiveRecord::Base
  #belongs_to :flow
  #belongs_to :sensor
end
class Instruction < ActiveRecord::Base
  #belongs_to :flow
  #belongs_to :actuator 
end

plugin.opos.on_signal("create_measure") do |name,config|
  if !Device.exists?(:config_name => config["path"])
    dev = Device.create(:config_name => config["path"],
                        :model => config["model"],
                        :path_dbus => config["path"])
                        #:card_id => Card.find(:first, :conditions => [ "config_name = ?",  meas.instance_variable_get(:@card_name)]))
                        
    Sensor.create(:device_id => dev.id, :unit => config["informations"]['unit'])
  end
end

plugin.opos.on_signal("create_actuator") do |name,config|
  if !Device.exists?(:config_name => config["path"])
    dev = Device.create(:config_name => config["path"],
                        :model => config["model"],
                        :path_dbus => config["path"])
                        #:card_id => Card.find(:first, :conditions => [ "config_name = ?", act.instance_variable_get(:@card_name)])) 
    Actuator.create(:device_id => dev.id, :interface => config["driver"]["interface"]) 
  end
end

plugin.opos.on_signal("new_measure") do |name, value, option|
    flow = Flow.create(:date  => Time.new ,:value => value) 
    device =  Device.find(:first, :conditions => { :config_name => name })
    sensor =  Sensor.find(:first, :conditions => { :device_id => device.id })
    Measure.create(:flow_id => flow.id,:sensor_id => sensor.id) 
end

plugin.opos.on_signal("new_order") do |name, order, option|
    flow = Flow.create(:date  => Time.new ,:value => order) 
    device =  Device.find(:first, :conditions => { :config_name => name })
    actuator = Actuator.find(:first, :conditions => { :device_id => device.id })
    Instruction.create(:flow_id => flow.id,:actuator_id => actuator.id)
end

plugin.opos.on_signal("create_card") do |name,config|
    if !Card.exists?(:config_name => name)
      Card.create(:config_name => name, :path_dbus => name ) # model, usb id missing
    end
end

plugin.run
