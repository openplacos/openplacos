class ChangeUsers < ActiveRecord::Migration
  def self.up
    change_table :users do |table|
      table.has_many(:flows)
    end
  end

end
