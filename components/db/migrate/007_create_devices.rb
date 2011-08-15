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
