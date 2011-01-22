class Room
    
    attr_accessor :path, :sensors, :actuators, :room_backend
    
    def initialize(connection, path)
      @connect = connection
      @room_backend = connection.rooms[path]
      @path = path
    end

    def name
        if @path == "/"
            return "OpenplacOS"
        else
            return @path
        end
    end

end
