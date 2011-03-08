class Flow < ActiveRecord::Base 
  belongs_to :measure
  belongs_to :instruction
end
