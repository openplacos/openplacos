class Actuator

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
    
    def get_methods
      meth = @backend.methods.keys
      meth.delete("state")
      return meth
    end
    
end
