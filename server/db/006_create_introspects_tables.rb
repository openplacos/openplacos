class CreateIntrospectsTables < ActiveRecord::Migration
  def self.up
    create_table :introspects do |t|
      t.text     :command_string
      t.datetime :ttl_date
      t.text     :cached_data
    end
  end

  def self.down
    drop_table :introspects
  end
end
