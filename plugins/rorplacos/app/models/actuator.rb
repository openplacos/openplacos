class Actuator < ActiveRecord::Base
    belongs_to :devices
    has_many :instructions
    has_many :flows , :through => :instructions
    
    attr_reader :path,:backend

    def initialize(connection, path)
       @connect = connection
       @path = path
       @backend = connection.actuators[@path]
        # @state = node.object['org.openplacos.server.actuator'].state[0]['name']
        # @state ||= "unknown"
        # @methods = node.object['org.openplacos.server.actuator'].methods.keys
        # @methods.delete('state')
    end
    
    def state
      s = @backend.state[0]["name"]
      if s.nil?
        s = "NA"
      end
      return s
    end
    
    def value
      s = @backend.state[0]["value"]
      if s.nil?
        s = 0
      end
      return s
    end
    
    def get_methods
      meth = @backend.methods.keys
      meth.delete("state")
      return meth
    end
    
    
    def generate_graph(start_date,end_date)
      inst = Device.find(:first, :conditions => {:config_name => @path}).actuator.flows.where("date >= :start_date and date <= :end_date",{:start_date => start_date, :end_date => end_date}).order("date ASC")
      
      ret = [];
      
      inst.each_index { |ist|
        ret.push([inst[ist].date.to_i*1000-1, inst[ist-1].value])
        ret.push([inst[ist].date.to_i*1000, inst[ist].value]) 
      }
      
      ret.push([Time.now.to_i*1000, to_float(self.value)])
      return ret
    end 
    
  def to_float(bool)
    return 1 if bool.is_a?(TrueClass)
    return 0 if bool.is_a?(FalseClass)
    return bool.to_f
  end  
    
end
