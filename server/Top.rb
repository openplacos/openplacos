class Top

  attr_reader :components, :config_export, :exports, :log
  attr_accessor :debug_mode_activated

  def self.instance
    @@instance
  end
  
  # Config file path
  # Dbus session reference
  # Internal Dbus
  # Logguer instance
  def initialize (config_, internalservice_, log_)
    # Parse yaml
    begin
      @config           =  YAML::load(File.read(config_))
    rescue Psych::SyntaxError
      Globals.error_before_start("Config file #{config_} can't be parsed, please check the syntax",log_)
    end
    @internalservice  = internalservice_
    @config_component = @config["component"] || {}
    @config_export    = @config["export"] || {}
    @config_mapping   = @config["mapping"] || {}
    @log              = log_
    @@instance        = self

    # Event_handler creation
    @event_handler = Event_Handler.instance
    @internalservice.export(@event_handler)

    # Any component in debug mode ?
    @debug_mode_activated = false


    # Hash of available dbus objects (measures, actuators..)
    # the hash key is the dbus path
    @components = Array.new
    @exports    = Hash.new

  end

  def inspect_components
    @config_component.each do |component|
      @components << Component.new(component) # Create a component object
    end 
    
    # introspect phase
    @components.each  do |component|
      component.introspect   # Get informations from component -- threaded
    end

    # analyse phase => creation of Pins
    @components.each  do |component|
      component.analyse   # Create pin objects according to introspect
    end
  end

  def  create_exported_object
    @config_export.each do |export|
      @exports[export] = Export.new(export)
    end
  end

  def map
   disp =  Dispatcher.instance
    @config_mapping.each do |wire|
      disp.add_wire(wire) # Push every wire link into dispatcher
    end
  end

  def expose_component
    @components.each  do |component|
      component.expose()   # Exposes on dbus interface service
      component.outputs.each do |p|
        @internalservice.export(p)
      end
    end
  end

  def launch_components
    @components.each  do |component|
      component.launch # Launch every component -- threaded
    end

    @components.each  do |component|
       component.wait_for # verify component has been launched 
    end
  end
  
  def update_exported_ifaces 
    @exports.each_value do |export|
      if !Dispatcher.instance.is_bind?(export.dbus_name)
        Globals.error("#{export.dbus_name} is not map", 43)
      end
      export.update_ifaces
    end
  end
  
  def quit
    @event_handler.quit
  end
  
end # End of Top
