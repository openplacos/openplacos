class CreateInterfacesTables < ActiveRecord::Migration
  def self.up
    create_table :interfaces do |t|
      t.string :name
      t.timestamps
      t.references(:resource)
    end
  end

  def self.down
    drop_table :interfaces
  end
end
