class Tracker 

  def initialize(top_,frequency_)
    @top = top_
    @frequency = frequency_
    @ifacetoread = list_of_iface_to_read
    puts "Tracker initialized"
  end
  
  def create_thread
    @thread = Thread.new do 
      Thread.current.abort_on_exception = true
      loop do
        @ifacetoread.each do |iface|
            value = Dispatcher.instance.call(iface["name"],iface["iface"], :read,{})[0]
            iface["model"].reads.create({:value => value})
        end
        sleep @frequency
      end
    end
  end
  
  
  def track
    create_thread()
  end
  
  def list_of_iface_to_read
    out = Array.new
    @top.exports.each_pair do |name, obj|
      intro = obj.pin_web.introspect
      intro.each_pair do |iface,met|
        if met.include?("read")
          readobj = Hash.new
          readobj["name"] = name
          readobj["iface"] = iface
          model = Resource.find_by_name(name).interfaces.find_by_name(iface)
          if model.nil?
            puts "Can't find model #{name} : #{iface}"
          else
            readobj["model"] = model
            out << readobj
          end
        end
      end
    end
    return out
  end

end
