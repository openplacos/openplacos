class CreateReadsTables < ActiveRecord::Migration
  def self.up
    create_table :reads do |t|
      t.column :value, :blob
      t.timestamps
      t.references(:interface)
    end
  end

  def self.down
    drop_table :reads
  end
end
