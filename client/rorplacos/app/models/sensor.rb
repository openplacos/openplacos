class Sensor

    attr_reader :path, :value, :unit

    def initialize(node)
        @path = node.object.path
        @value = node.object['org.openplacos.server.measure'].value[0]
        #@unit = node.object['org.openplacos.server.config'].getConfig['informations']['unit']
    end

end
