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
