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

