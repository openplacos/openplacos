class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |table|
      table.column :login, :string, :limit => 80, :null => false
      table.column :first_name, :string, :limit => 80
      table.column :last_name, :string, :limit => 80
      table.column :email, :string, :limit => 80
      table.column :language, :string, :limit => 80
      table.column :style, :string, :limit => 80
    end
  end

  def self.down
    drop_table :users
  end
end

class CreateCards < ActiveRecord::Migration
  def self.up
    create_table :cards do |table|
      table.column :config_name, :string, :limit => 80
      table.column :model, :string, :limit => 80
      table.column :usb_id, :integer
      table.column :path_dbus, :string
    end
  end
  
  def self.down
    drop_table :cards   
  end
end

class CreateDevices < ActiveRecord::Migration
  def self.up
    create_table :devices do |table|
      table.column :config_name, :string, :limit => 80
      table.column :model, :string, :limit => 80
      table.column :path_dbus, :string
      table.references(:card) 
    end
  end
  
  def self.down
    drop_table :devices    
  end
end


class CreateSensors < ActiveRecord::Migration
  def self.up
    create_table :sensors do |table|
      table.column :unit, :string, :limit => 80
      table.references(:device) 
    end
  end
  
  def self.down
    drop_table :sensors    
  end
end


class CreateActuators < ActiveRecord::Migration
  def self.up
    create_table :actuators do |table|
      table.column :interface, :string, :limit => 80
      table.references(:device) 
    end
  end
  
  def self.down
    drop_table :actuators    
  end
end

class CreateFlows < ActiveRecord::Migration
  def self.up
    create_table :flows do |table|
      table.column :date, :datetime 
      table.column :value, :float, :null => false
      table.references(:user) 
    end
  end
  
  def self.down
    drop_table :flows    
  end
end


class CreateMeasures < ActiveRecord::Migration
  def self.up
    create_table :measures do |table|
      table.references(:flow, :sensor) 
    end
  end
  
  def self.down
    drop_table :measures    
  end
end

class CreateInstructions < ActiveRecord::Migration
  def self.up
    create_table :instructions do |table|
      table.references(:flow, :actuator) 
    end
  end
  
  def self.down
    drop_table :actuator    
  end
end






