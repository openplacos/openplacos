#/usr/bin/ruby -w

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
#   Opos classes for database binding.


require 'rubygems'
require 'active_record'

class Database 
  
  class User < ActiveRecord::Base
  end
  class Card < ActiveRecord::Base
  end
  class Device < ActiveRecord::Base 
  end
  class Sensor < ActiveRecord::Base 
  end
  class Actuator < ActiveRecord::Base 
  end
  class Flow < ActiveRecord::Base 

  end
  class Measure < ActiveRecord::Base
  end
  class Instruction < ActiveRecord::Base 
  end

  attr_reader :measures, :actuators
  attr_reader :drivers
  def initialize(config_)
    #1 Config for DB
    
    if config_['database']
      
      $global.trace "Connect to database."
      
      #Connect to database
      ActiveRecord::Base.establish_connection(
                                              :adapter => config_['database']['adapter'],
                                              :host => config_['database']['host'],
                                              :user => config_['database']['user'],
                                              :password => config_['database']['password'],
                                              :database => config_['database']['name']
                                              )
      
      $global.trace "Connected"
      
      #create tables if doesnt exist.
      create_opos_tables      
      

      
    end
  end
  
  def create_opos_tables 
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
          table.column :room, :string, :limit => 80
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
  end
  
  def store_config(cards_, measures_, actuators_)
    #1 card list from top
    #2 measure list from top
    #3 actuator list from top



    cards_.each_pair{ |name, card|
      if !Card.exists?(:config_name => name)
        Card.create(:config_name => name, :path_dbus => card.path_dbus ) # model, usb id missing
      end
    }
    

 

    measures_.each_pair{ |name, meas|
       if !Device.exists?(:config_name => name)
        dev = Device.create(:config_name => name,
                            :model => meas.instance_variable_get(:@device_model) ,
                            :room => meas.instance_variable_get(:@room) ,
                            :path_dbus => meas.proxy_iface.object.path,
                            :card_id => Card.find(:first, :conditions => [ "config_name = ?",  meas.instance_variable_get(:@card_name)]))
                            
        Sensor.create(:device_id => dev.id, :unit => meas.informations['unit'])
      end
    }
    
    actuators_.each_pair{ |name, act|
      if !Device.exists?(:config_name => name)
        dev = Device.create(:config_name => name,
                            :model => act.instance_variable_get(:@device_model) ,
                            :room => act.instance_variable_get(:@room),
                            :path_dbus => act.proxy_iface.object.path,
                            :card_id => Card.find(:first, :conditions => [ "config_name = ?", act.instance_variable_get(:@card_name)])) 
        Actuator.create(:device_id => dev.id, :interface => act.config["driver"]["interface"]) 
      end
    }
    
  end

  
  
end
