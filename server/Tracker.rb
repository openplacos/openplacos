class Tracker 

  def initialize(top_,frequency_)
    @top = top_
    @frequency = frequency_
    @ifacetoread = list_of_iface_to_read
    lastread = Readhour.last
    if !lastread.nil?
      @lasthour = floor_hour(lastread.created_at)
    else
      @lasthour = floor_hour(Time.now) #Time.now.hour
    end
    lastread = Readday.last
    if !lastread.nil?
      @lastday = floor_day(lastread.created_at)
    else
      @lastday = floor_day(Time.now) #Time.now.hour
    end
  end
  
  def floor_hour(time)
    return (time - time.sec - time.min*60)
  end
  
  def floor_day(time)
    return (time - time.sec - time.min*60 - time.hour*3600)
  end
  
  def create_thread
    @thread = Thread.new do 
      Thread.current.abort_on_exception = true
      loop do
        sleep @frequency
        # create reads 
        reads = Array.new
        @ifacetoread.each do |iface|
            value = Dispatcher.instance.call(iface["name"],iface["iface"], :read,{})[0]
            reads << {:value => value,:interface_id => iface["model"].id}
        end
        Read.create(reads)
        
        # check if hour has changed
        if @lasthour != floor_hour(Time.now)
          # if true creates readhour
          readhours = Array.new
          time = Time.now
          @ifacetoread.each do |iface|
            value = Read.where(:created_at => (@lasthour)..(@lasthour + 1.hour),:interface_id => iface["model"].id).average('value')
            readhours << {:value => value,:interface_id => iface["model"].id, :created_at => (@lasthour + 1.hour) } if !value.nil?
            #FIXME : change the time of the record
          end
          Readhour.create(readhours)
          @lasthour = floor_hour(time)
        end
        
        # check if day has changed
        if @lastday != floor_day(Time.now)
          # creates readday
          readdays = Array.new
          time = Time.now
          @ifacetoread.each do |iface|
            value = Readhour.where(:created_at => (@lastday)..(@lastday + 1.day),:interface_id => iface["model"].id).average('value')
            readdays << {:value => value,:interface_id => iface["model"].id, :created_at => (@lastday + 1.day)} if !value.nil?
            #FIXME : change the time of the record
          end
          Readday.create(readdays)
          @lastday = floor_day(time)
        end
        
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
