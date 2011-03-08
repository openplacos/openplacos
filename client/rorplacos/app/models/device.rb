class Device < ActiveRecord::Base
  belongs_to :card
  has_many :sensors
  has_many :actuators
end
