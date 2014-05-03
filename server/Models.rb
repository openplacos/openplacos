class Resource < ActiveRecord::Base

  validates_uniqueness_of :name
  has_many :interfaces
  
end

class Interface < ActiveRecord::Base

  belongs_to :resource
  has_many :reads
  has_many :readhours
  has_many :readdays
end

class Read < ActiveRecord::Base

  belongs_to :interface
  
end

class Readhour < ActiveRecord::Base

  belongs_to :interface
  
end

class Readday < ActiveRecord::Base

  belongs_to :interface
  
end

class Introspect <  ActiveRecord::Base
end
