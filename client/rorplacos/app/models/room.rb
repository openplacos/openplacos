class Room
    
    attr_accessor :path, :sensors, :actuators, :room_backend, :connect
    
    def initialize(connection, path)
      @connect = connection
      @path = path + "/"
      @room_backend = connection.rooms[@path]
      @sensors = Hash.new
      @actuators = Hash.new

      @room_backend.objects.each_pair{ |key, value|
        if value.has_iface? 'org.openplacos.server.measure'
          @sensors.store(value,  Sensor.new(value))
          puts "measure!"
        elsif value.has_iface? 'org.openplacos.server.actuator'
          @actuators.store(value,  Actuator.new(value))
          puts "actu!"
        end
      }

    end

    def name
        if @path == "/"
            return "OpenplacOS"
        else
            return @path
        end
    end

end
