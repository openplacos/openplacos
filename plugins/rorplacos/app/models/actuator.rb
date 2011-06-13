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
    
    def generate_graph(time)
      inst = Device.find(:first, :conditions => {:config_name => @path}).actuator.flows.where("date >= :start_date",{:start_date => time.hour.ago }).order("date DESC")
      ret = Array.new
      ret << [Time.new.to_i, self.value]
      ret = inst.collect{ |m| [m.date.to_i*1000, m.value]}
      return ret
    end
    
    
end
