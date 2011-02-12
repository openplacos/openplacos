class Sensor

    attr_reader :path, :value, :unit, :backend, :node

    def initialize(node)
      @path = node.path
      @node = node
      @backend = node['org.openplacos.server.measure']
        # @value = node.object['org.openplacos.server.measure'].value[0]
        # @unit = node.object['org.openplacos.server.config'].getConfig['informations']['unit']
    end

end
