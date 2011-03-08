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
end
