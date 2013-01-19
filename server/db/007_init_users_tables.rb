class InitUsersTables  < ActiveRecord::Migration
  def self.up
    User.create :login => "root", :password => "root"
  end

  def self.down
  end
end
