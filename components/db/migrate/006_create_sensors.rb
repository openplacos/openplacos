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
