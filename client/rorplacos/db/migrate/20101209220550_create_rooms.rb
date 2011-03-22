class CreateRooms < ActiveRecord::Migration
  def self.up
    create_table :rooms do |t|
      t.string :name
      t.integer :parent_id

      t.timestamps
    end
  end

  def self.down
    drop_table :rooms
  end
end
