class Actuator

    attr_reader :path, :state, :methods

    def initialize(node)
        @path = node.object.path
        @state = node.object['org.openplacos.server.actuator'].state[0]['name']
        @state ||= "unknown"
        @methods = node.object['org.openplacos.server.actuator'].methods.keys
        @methods.delete('state')
    end
end
