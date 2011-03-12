class CreateConnexions < ActiveRecord::Migration
  def self.up
    create_table :connexions do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :connexions
  end
end
