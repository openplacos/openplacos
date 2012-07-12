ENV["DBUS_THREADED_ACCESS"] = "1" #activate threaded dbus

require "rubygems"
require 'dbus-openplacos'
require 'yaml' 
require "micro-optparse"

module LibComponent
  
  ACK = 0
  Error = 1
  # Common module to Input and Output
  module Pin
    
    def set_component(component_)
      @component=component_
    end
    
    # define a start method which will be executed on startup
    def on_startup(&block)
      self.singleton_class.instance_eval {
        define_method(:start , &block)
      }
    end
    
    # Return introspect object that can be delivered to openplacos server
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
    
    def buffer=(time_)
      self.extend(Buffer)
      @buffer_time = time_
      @buffer_last_value = Time.new(0)
    end

  end

  module Buffer
        
    #get the value from the buffer
    def get_buffer_value
      if Time.now - @buffer_last_value < @buffer_time
        return @buffer_value
      else 
        return nil
      end
    end
    
    def set_buffer_value(value_)
      @buffer_value = value_
      @buffer_last_value = Time.now
    end
  end

  # Instanciate an input pin to your component
  class Input
    include Pin
    attr_reader   :name, :interface
    attr_accessor :input, :last_iface_init

    # instaciate an input pin with its name and the interface this pin will support
    def initialize(pin_name_,iface_name_)
      @name      = pin_name_
      @interface = iface_name_      
      @input     = nil
      @last_iface_init = ""
    end

    # read method called by dbus
    # this method will
    # * turning off previous interface
    # * turn pin into input mode
    # * initialize current interface 
    # * and then made a read access
    # All these steps are optionnal and are in charge of component developper.
    def read_lib(*args)
      set_off # set_off last iface
      set_input_lib
      init_iface
      return read(*args)
    end

    # write method called by dbus
    # this method will
    # * turning off previous interface
    # * turn pin into input mode
    # * initialize current interface 
    # * and then made a read access
    # All these steps are optionnal and are in charge of component developper.
    def write_lib(*args)
      set_off # set_off last iface
      set_output_lib
      init_iface
      return write(*args)
    end
    
    # Event style for read definition
    # Can also be overloaded by developper
    def on_read(&block)
      self.singleton_class.instance_eval {
        define_method(:read , &block)
      }
    end
    
    # Event style for write definition
    # Can also be overloaded by developper
    def on_write(&block)
      self.singleton_class.instance_eval {
        define_method(:write , &block)
      }
    end

    private
           
    # Iface changed since last call, turn off previous one
    # Please implement exit method at your end
    def set_off()
      if (@last_iface_init != @interface)
        prev_iface = @component.get_input_iface(@name, @last_iface_init)
        if(prev_iface.respond_to?(:exit))
           prev_iface.exit()
        end     
      end
    end

    # If pin has to be set to input mode
    # Please implement set_input method at your end
    def set_input_lib
      if (@input != 1) # 1 means input / 0 output
        if(self.respond_to?(:set_input))
          self.set_input()
        end
        @input = 1
      end 
      @last_iface_init = @interface
    end

    # If pin has to be set to output mode
    # Please implement set_output method at your end
    def set_output_lib
      if (@input != 0) # 1 means input / 0 output
        if(self.respond_to?(:set_output))
          self.set_output()
        end
        @input = 0
      end     
    end

    # Initialize this interface
    # Please implement init method at your end
    def init_iface
      if(@last_iface_init != @interface)
        if(self.respond_to?(:init))
          self.init
        end
      end
      @component.set_last_iface_init(@name, @interface) # set last_iface_name
    end

  end

  class Output 
    include Pin
    attr_reader :name, :interface
    def initialize(pin_name_,iface_name_,meth_ = "rw")
      @name = pin_name_
      @interface = iface_name_ 
      @meth = meth_
      @proxy = nil
      
      # introspect is defined according to read and write methods
      if @meth.include?("r")
        instance_eval { self.extend(Read) }
      end
      if @meth.include?("w")
        instance_eval { self.extend(Write) }
      end
      
      init if self.respond_to? :init
    end
    
    module Read
      # Make a read access on this pin
      # Please provide arguments needed according to interface definition
      def read(*args)
        if self.respond_to?(:get_buffer_value)
          buf = get_buffer_value()
          ret = buf || read_on_proxy(*args)
        else
          ret = read_on_proxy(*args)
        end
        return ret
      end
      
      private
      
      def read_on_proxy(*args)
        val = @proxy.read(*args)[0]
        set_buffer_value(val) if self.respond_to?(:set_buffer_value)
        return val
      end
      
    end
    
    module Write
    # Make a write access on this pin
    # Please provide arguments needed according to interface definition
      def write(*args)
        return @proxy.write(*args)[0]
      end
    end
    
    def connect(proxy_)
      @proxy = proxy_["org.openplacos.#{@interface}"]
      if @proxy.nil?
        quit_server(255, "The interface org.openplacos.#{@interface} is not available for pin #{self.name}")
      end
    end    

    
  end
  

  # Entry point of LibComponent
  class Component
    attr_reader :options, :bus ,:name, :main

    # Please provide ARGV in argument
    def initialize(argv_ = ARGV)
      @argv        = argv_
      @description = ""
      @bus         = nil
      @main        = nil
      @inputs      = Array.new
      @outputs     = Array.new
      @parser      = Parser.new
      @parser.option(:introspect, "Return introspection of the component",{})
      @parser.option(:debug, "debug flag")
      yield self if block_given?      
      @options = @parser.process!(@argv)
      @name = @options[:name].downcase
    end
    
    # provide a string describing your component  
    def description(desc_)
      @description   = desc_
      @parser.banner = desc_
    end
    
    # Set version of your component
    def version(version_)
      @parser.version = version_
    end
    
    # Default name for identiying your component
    def default_name(name_)
      @parser.option(:name,"Dbus name of the composant", :default => name_)
    end
    
    # define an option in command line (micro-optparse syntaxe)
    def option(*args_)
      @parser.option(*args_)
    end
    
    # Push pin to component
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
    
    # print function
    # please use this method rather than puts
    def print_debug(arg_)
      if !@options[:introspect]
        puts arg_
      end
    end

    # Let's rock! Run the component
    def run
      # execute startup methods
      @inputs.each do |inp|
        inp.start if inp.respond_to?(:start)
      end
      @outputs.each do |outp|
        outp.start if outp.respond_to?(:start)
      end
      
      intro = introspect
      if @options[:introspect]
        print intro.to_yaml
      else
        @bus = create_bus
        
        #create dbus input pins
        dbusinputs = LibComponent::DbusInput.create_dbusinputs_from_introspect(intro["input"]["pin"],self)
        name = "org.openplacos.components.#{@name.downcase}"
        if (@bus.proxy.ListNames[0].member?(name))
          quit_server(255, "#{name} already exists")
        end
        @service = @bus.request_service(name)
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
                
        @main = DBus::Main.new
        @main << @bus
        @main.run
      end
    end
    
    # Event style for quit method
    def on_quit(&block)
      self.singleton_class.instance_eval {
        define_method(:quit , &block)
      }
    end    
    
    # Parse inputs and outputs to communicate with server
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
    
    # Method called when signal "quit" from server is raised
    def quit_callback
      self.quit if self.respond_to?(:quit)
      @main.quit if !@main.nil?
    end

    
    # Print an error message and make the server quit
    def quit_server(status_, str_)
      $stderr.puts str_
      if (!@options.nil?) && !@options[:debug]
        bus       = DBus::ASessionBus.new
        server    = bus.service("org.openplacos.server.internal")
        opos      = server.object("/plugins")
        opos.introspect
        opos.default_iface = "org.openplacos.plugins"
        opos.exit(status_, str_)
      else
        Process.exit 1
      end
      
    end
    
    # Only quit component
    # Only use this method if component cannot connect to server
    def self.quit(status_,str_)
      $stderr.puts str_
      exit(status_)
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
    
    # Create all dbus I/O for this pin.
    # Called internally by component
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
    
    # Create all dbus I/O for this pin.
    # Called internally by component   
    def self.create_dbusoutputs_from_introspect(intro_,component_)
      pin = Array.new
      intro_.each { |name, definition|
        p = self.new(component_.bus,"/#{component_.name}#{name}")
        begin
          p.introspect
        rescue DBus::Error
          quit(255, "From #{component_.name}: Introspect of pin /#{component_.name}#{name} failed \nOpenplacos server is probably unreachable")
        rescue 
          quit_server(255, "From #{component_.name}: Introspect of pin /#{component_.name}#{name} failed \n")
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
      end
    end
    
  end
end

