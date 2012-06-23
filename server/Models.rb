class Resource < ActiveRecord::Base

  validates_uniqueness_of :name
  has_many :interfaces
  
end

class Interface < ActiveRecord::Base

  belongs_to :resource
  has_many :reads
end

class Read < ActiveRecord::Base

  belongs_to :interface
  
end
