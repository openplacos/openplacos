class Sensor

    attr_reader :path, :backend

    def initialize(connection, path)
      @connect = connection
      @path = path
      @backend = connection.sensors[@path]
        # @value = node.object['org.openplacos.server.measure'].value[0]
        # @unit = node.object['org.openplacos.server.config'].getConfig['informations']['unit']
    end

end
