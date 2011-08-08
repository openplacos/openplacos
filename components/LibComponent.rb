ENV["DBUS_THREADED_ACCESS"] = "1" #activate threaded dbus

require "rubygems"
require 'dbus-openplacos'
require "micro-optparse"
require 'yaml' 


module LibComponent

  class Input
    attr_reader   :name, :interface
    attr_accessor :input, :last_iface_init

    def initialize(pin_name_,iface_name_)
      @name      = pin_name_
      @interface = iface_name_      
      @input     = nil
      @last_iface_init = ""
    end
    
    def set_component(component_)
      @component=component_
    end

    def introspect
      iface = Hash.new
      pin = Hash.new
      meth = Array.new

      if self.respond_to?(:read)
        meth << "read"
      end
      if self.respond_to?(:write)
        meth << "write"
      end
      iface[@interface] = meth
      pin[@name] = iface
      return pin
    end
    
    def set_off()
      if (@last_iface_init != @interface) # Iface changed, turn off previous one
        prev_iface = @component.get_input_iface(@interface, @last_iface_init)
         if(prev_iface.respond_to?(:exit))
           eval("prev_iface."+"()")
        end     
      end
    end

    def set_input_lib
      if (@input != 1) # 1 means input / 0 output
        if(self.respond_to?(:set_input))
          self.set_input()
        end
        @input = 1
      end     
    end

    def set_output_lib
      if (@input != 0) # 1 means input / 0 output
        if(self.respond_to?(:set_output))
          self.set_output()
        end
        @input = 0
      end     
    end

    def init_iface
      if(@last_iface_init != @interface)
        if(self.respond_to?(:init))
          self.init
        end
      end
      @component.set_last_iface_init(@name, @interface) # set last_iface_name
    end
    
    def read_lib(*args)
      set_off # set_off last iface
      set_input_lib
      init_iface
      return read(*args)
    end

    def write_lib(*args)
      set_off # set_off last iface
      set_output_lib
      init_iface
      return write(*args)
    end

    def on_read(&block)
      self.singleton_class.instance_eval {
        define_method(:read , &block)
      }
    end
    
    def on_write(&block)
      self.singleton_class.instance_eval {
        define_method(:write , &block)
      }
    end
    
  end

  class Output 
    attr_reader :name, :interface
    def initialize(pin_name_,iface_name_,meth_ = "rw")
      @name = pin_name_
      @interface = iface_name_ 
      @meth = meth_
      @proxy = nil
    end
    
    def set_component(component_)
      @component=component_
    end   

    def introspect
      iface = Hash.new
      pin = Hash.new
      meth = Array.new
      
      if @meth.include?("r")
        meth << "read"
      end
      if @meth.include?("w")
        meth << "write"
      end
      
      iface[@interface] = meth
      pin[@name] = iface
      return pin
    end
    
    def read(*args)
      return @proxy.read(*args)[0]
    end
    
    def write(*args)
      return @proxy.write(*args)[0]
    end
    
    def connect(proxy_)
      @proxy = proxy_["org.openplacos.#{@interface}"]
      if @proxy.nil?
        LibError.raise("The interface org.openplacos.#{@interface} is not available for pin #{self.name}")
      end
    end    
  end
  
  class Component
    attr_reader :options, :bus ,:name

    def initialize(argv_ = ARGV)
      @argv = argv_
      @description = ""
      @bus = nil
      @main = nil
      @inputs = Array.new
      @outputs = Array.new
      @parser = Parser.new
      @parser.option(:introspect, "Return introspection of the component",{})
      @parser.option(:debug, "debug flag")
      yield self if block_given?      
      @options = @parser.process!(@argv)
      @name = @options[:name].downcase
    end
    
    def description(desc_)
      @description = desc_
      @parser.banner = desc_
    end
    
    def version(version_)
      @parser.version = version_
    end
    
    def default_name(name_)
      @parser.option(:name,"Dbus name of the composant", :default => name_)
    end
    
    def option(*args_)
      @parser.option(*args_)
    end
    
    def <<(pin_)
      if pin_.kind_of?(Input)
        @inputs << pin_
      elsif pin_.kind_of?(Output)
        @outputs << pin_
      elsif pin_.kind_of?(Array) 
        # push an array of pin
        pin_.each { |p|
          self << p
        }
      end
      pin_.set_component(self)
    end
    
    def run
      intro = self.introspect
      if @options[:introspect]
        print intro.to_yaml
      else
        @bus = create_bus
        
        #create dbus input pins
        dbusinputs = LibComponent::DbusInput.create_dbusinputs_from_introspect(intro["input"]["pin"],self)
        @service = @bus.request_service("org.openplacos.components.#{@name.downcase}")
        dbusinputs.each { |pin|
          @service.export(pin)
        }
        
        #create and connect output pins
        if options[:debug]
          @dbusoutputs = LibComponent::DebugOutput.create_dbusoutputs_from_introspect(intro["output"]["pin"],self)
        else
          @dbusoutputs = LibComponent::DbusOutput.create_dbusoutputs_from_introspect(intro["output"]["pin"],self)
          @servicesignal = Servicesignal.new(@bus, self) # listen for service signal from server
        end
        
        Signal.trap('INT') do 
          self.quit_callback
        end
        
        #  dbuscomponent = LibComponent::DbusComponent.new(self)
        #  @service.export(dbuscomponent)
        
        
        @main = DBus::Main.new
        @main << @bus
        @main.run
      end
    end    
    
    def introspect
      inputs_h = Hash.new
      outputs_h = Hash.new
      
      #call all inputs introspect and merge values
      @inputs.each { |input|
        inputs_h.merge!(input.introspect) { |key, old, new| old.merge(new) }
      }
      #call all outputs introspect and merge values
      @outputs.each { |output|
        outputs_h.merge!(output.introspect) { |key, old, new| old.merge(new) }
      }
      
      res = Hash.new
      res["input"] = {"pin" => inputs_h}
      res["output"] = {"pin" => outputs_h}
      return res
    end
    
    def get_input_iface(object_name_,iface_name_)
      @inputs.each { |input|
        return input if (input.name==object_name_) and (input.interface == iface_name_)
      }
      return nil
    end

    def set_input(object_name_, input_)
      @inputs.each { |input|
        input.input= input_ if (input.name==object_name_) 
      }
      return nil     
    end

    def set_last_iface_init(object_name_, iface_name_)
      @inputs.each { |input|
        input.last_iface_init = iface_name_ if (input.name==object_name_) 
      }
      return nil     
    end
    
    def get_output_iface(object_name_,iface_name_)
      @outputs.each { |output|
        return output if (output.name==object_name_) and (output.interface == iface_name_)
      }
      return nil
    end
    
    def on_quit(&block)
      self.singleton_class.instance_eval {
        define_method(:quit , &block)
      }
    end
    
    def quit_callback
      self.quit if self.respond_to?(:quit)
      @main.quit if !@main.nil?
    end
    
    private
    
    def create_bus
      return DBus::ASessionBus.new
    end
    
  end
  
  class DbusInput < DBus::Object
    
    def initialize(name)
      super(name)
    end
    
    def self.create_dbusinputs_from_introspect(intro_,component_)
      pin = Array.new
      intro_.each { |name, definition|
        p = self.new(name)
        definition.each { |iface, meths|
          component_input = component_.get_input_iface(name,iface)
          p.singleton_class.instance_eval do
            dbus_interface "org.openplacos.#{iface}" do
              meths.each { |m|
                add_dbusmethod m.to_sym do |*args|
                  return component_input.send(m+"_lib",*args)
                end 
              }
            end
          end
        }
        pin << p
      }
      return pin
    end
    
    private
    
    def self.add_dbusmethod(sym_,&block)
      case sym_
      when :read
        prototype = "out return:v, in option:a{sv}"
      when :write
        prototype = "out return:v, in value:v, in option:a{sv}"
     end
      dbus_method(sym_,prototype,&block)
    end
    
  end
  
  class DbusOutput < DBus::ProxyObject
    
    def initialize(bus_,name_)
      @name = name_
      @bus = bus_
      super(@bus,"org.openplacos.server.internal",@name)
    end
    
    def self.create_dbusoutputs_from_introspect(intro_,component_)
      pin = Array.new
      intro_.each { |name, definition|
        p = self.new(component_.bus,"/#{component_.name}#{name}")
        begin
          p.introspect
        rescue 
          LibError.raise("Introspect of pin /#{component_.name}#{name} failed \nThe openplacos server is probably unreachable")
        end
        definition.each_key { |iface|
          component_output = component_.get_output_iface(name,iface)
          component_output.connect(p)
        }
        pin << p
      }
      return pin
    end
    
  end
  
  # a class for debugging which print the output
  class DebugOutput 
    attr_reader :name
    
    def initialize(name_)
      @name = name_
    end
    
    def [](propname)
      return self
    end
    
    def self.create_dbusoutputs_from_introspect(intro_,component_)
      pin = Array.new
      intro_.each { |name, definition|
        p = self.new("/#{component_.name}#{name}")
        
        definition.each_key { |iface|
          component_output = component_.get_output_iface(name,iface)
          component_output.connect(p)
        }
        pin << p
      }
      return pin
    end
    
    def read(*args)
      puts "Read on #{self.name} : #{args.inspect}"
      return [0]      
    end
    
    def write(*args)
      puts "Write on #{self.name} : #{args.inspect}"
      return [0]
    end
    
  end
  
  class LibError
    def self.raise(str_)
      puts str_
      exit(255)
    end
  end
  
  # for component specific dbus object
  class DbusComponent < DBus::Object
    def initialize(component_)
      @component = component_
      super("/component")
    end

    dbus_interface "org.openplacos.component" do 
      dbus_method :quit do
        Thread.new { 
          sleep 2
          @component.quit_callback
        }
        return 0
        end
    end
  end


  class Servicesignal 
    
    def initialize(bus_, component_)
      @bus       = bus_
      @component = component_
      @server    = @bus.service("org.openplacos.server.internal")
      @opos      = @server.object("/plugins")
      @opos.introspect
      @opos.default_iface = "org.openplacos.plugins"

      @opos.on_signal("quit") do
        @component.quit_callback
        Process.exit 0
      end
    end
    
  end

end
