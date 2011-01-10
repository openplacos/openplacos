class Room
    
    attr_accessor :path, :sensors, :actuators, :rooms
    
    def initialize(service, path)
        @service = service
        @path = path
        @sensors, @actuators, @rooms = [], [], []
        if @path == "/"
            node = @service.root
        else
            node = @service.get_node(@path)
        end
        puts "path " + @path
        node.each_pair do |key,value|
            unless key=="Debug" or key=="server"
                if value.object.nil?
                    if path == "/"
                        room_path = @path + key
                    else
                        room_path = @path + "/" + key
                    end
                    @rooms << Room.new(@service, room_path)
                else
                    if value.object.has_iface? 'org.openplacos.server.measure'
                        @sensors << Sensor.new(value)
                        puts "measuer!"
                    elsif value.object.has_iface? 'org.openplacos.server.actuator'
                        @actuators << Actuator.new(value)
                        puts "actu!"
                    end
                end
            end
        end
    end

    def name
        if @path == "/"
            return "OpenplacOS"
        else
            return /([a-zA-Z0-9]+)$/.match(@path)[1]
        end
    end

end
