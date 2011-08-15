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
