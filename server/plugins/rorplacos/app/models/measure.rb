class Measure < ActiveRecord::Base
  belongs_to :sensor
  belongs_to :flow
end
