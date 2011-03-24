class CreateActuators < ActiveRecord::Migration
  def self.up
    create_table :actuators do |t|
      t.string :name
      t.float :state
      t.integer :room_id

      t.timestamps
    end
  end

  def self.down
    drop_table :actuators
  end
end
