class Measure < ActiveRecord::Base
  belongs_to :sensor
  has_one :flow
end
