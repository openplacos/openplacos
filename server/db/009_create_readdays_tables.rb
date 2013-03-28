class CreateReaddaysTables < ActiveRecord::Migration
  def self.up
    create_table :readdays do |t|
      t.column :value, :blob
      t.datetime :created_at
      t.references(:interface)
    end
  end

  def self.down
    drop_table :readdays
  end
end
