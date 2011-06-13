class Instruction < ActiveRecord::Base
  belongs_to :actuator
  belongs_to :flow
end
