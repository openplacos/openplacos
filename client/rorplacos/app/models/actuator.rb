class Actuator

    attr_reader :path, :state, :backend, :node

    def initialize(node)
        @path = node.path
        @node = node
        @backend = node['org.openplacos.server.actuator']
        # @state = node.object['org.openplacos.server.actuator'].state[0]['name']
        # @state ||= "unknown"
        # @methods = node.object['org.openplacos.server.actuator'].methods.keys
        # @methods.delete('state')
    end
end
