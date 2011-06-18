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
