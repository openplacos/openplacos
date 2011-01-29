class Room
    
    attr_accessor :path, :sensors, :actuators, :room_backend, :connect
    
    def initialize(connection, path)
      @connect = connection
      @path = path + "/"
      @room_backend = connection.rooms[@path]
    end

    def name
        if @path == "/"
            return "OpenplacOS"
        else
            return @path
        end
    end

end
