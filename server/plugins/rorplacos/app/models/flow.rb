class Flow < ActiveRecord::Base 
  has_one :measure
  has_one :instruction
end
