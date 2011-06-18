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
