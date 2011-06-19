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
      inst = Device.find(:first, :conditions => {:config_name => @path}).actuator.flows.where("date >= :start_date and date <= :end_date",{:start_date => start_date, :end_date => end_date}).order("date DESC")
      
      slice_size = [inst.size/500,1].max.to_i
      
      ret = [];
      
      inst.each_slice(slice_size) { |m| ret.push([m[0].date.to_i*1000, m[0].value]) }
    
      return ret
    end   
    
end
