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
