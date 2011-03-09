class Device < ActiveRecord::Base
  belongs_to :card
  has_one :sensor
  has_one :actuator
end
