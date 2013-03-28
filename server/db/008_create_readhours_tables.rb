class CreateReadhoursTables < ActiveRecord::Migration
  def self.up
    create_table :readhours do |t|
      t.column :value, :blob
      t.datetime :created_at
      t.references(:interface)
    end
  end

  def self.down
    drop_table :readhours
  end
end
