class Instruction < ActiveRecord::Base
  belongs_to :actuator
  has_one :flow
end
