# OpenplacOS programmer guide #

OpenplacOS has been conceived to easily extend it. 

## Components ##

Components comuunicates with openplacOS server through d-bus. DBus is an inter-process communication system. Using dbus makes you totally free of writing your component in whatever langage you want.

However, if you just want to start writing your component, we've developped a Ruby library (a gem) to help you start in.

### LibComponent - the easy way ###

To start with LibComponent, the prerequesite is to know developing in ruby. If no, just look to some tutorials, it is not over-complicated.

#### Coding tutorial ####

Let's take an example of a basic case: a logical inverser gate. Just look at the code:

```ruby
require "LibComponent.rb" # gem load

component = LibComponent::Component.new(ARGV) do |c|   
  c.description  "This is openplacos component for a Normaly open Relay"   
  c.version "0.1"   
  c.default_name "relaync"   
end
```

First, libcomponent needs to be instancianted and comes with some paramters. This is helpfull to help users understand and manage your component as if it were an application.

```ruby
component << Raw = LibComponent::Output.new("/raw","digital","w")
component << Switch = LibComponent::Input.new("/switch","digital.order.switch")
```

This is Pin instanciation. We've have 2 kinds of pins: output and input one. These pins are declared with a suffixe-name "/raw" and "/switch", and has an interface type "digital". Output pin needs also to need how these pin will be accessed (r, w, rw).

Input pins are assumed to respond to on_write and on_read methods. These methods must do answer according to its interface. Please refers to interface documentation to verify. To implement read and write, just proceed as this:

```ruby
Switch.on_write do |value, option|
  if value==1 or value==true
    @state = true
    return Raw.write(false,option)
  elsif value==0 or value==false
    @state = false
    return Raw.write(true,option)
  end
end

Switch.on_read do |option|
  return @state || false
end
```

Raw is an Ouput pin. This objects implements read and write methods depending of its interface.

OpenplacOS project can work using several component, please do respect interface conventions.

#### Launch your component ####

To verify and play with component, add this component to your config file in debug mode. Then, launch your server this way

### Process on dbus -- the hard way ###

If you need to write your component in another langage than ruby, this part is made for you.

OpenplacOS component is basically a process on dbus. This process is launched on dbus.

## Clients ##

The clients are the user-frontend. The communication between clients and the openplacos server is based on a REST api, and the user authentication is achieve by the oauth2 protocol.

### REST api ###

This section will describe URI you will be able to access to connect to your openplacos server. These URI will give you back string serialzed into JSON.

#### User ####

To access to personal informations, just do

```http
  GET /me
```    
This will return the current user name. Output is formatted like this:

```json
{"username": my_user_name }
```

#### Ressources ####

All ressources that have been exported can be accessed with:

```http
  GET /ressources
```    
This will return the list of ressources. A ressource is represented by a hash with two keys : "name" which is bassicaly the ressource identifier, and "interfaces" which contain the list of interfaces of the ressource.

Formatted json syntax:

```json
{ "name" : ressource_path,
  "interfaces" : {
    iface_name : [ array_of_methods ]
  }
}
```

example: 

```json
[
  { "name" : "/home/temperature",
    "interfaces" : {
      "analog.sensor.temperature.celcuis" : ["read"],
      "analog.sensor.temperature.farenheit" : ["read"],
      "analog.sensor.temperature.kelvin" : ["read"]
    }
  },
  { "name" : "/home/fan",
    "interfaces" : {
      "analog.order.dimmer" : ["read","write"],
      "digital.order.switch" : ["read","write"]
    }
  }
]
```

```http
  GET /ressources/ressource_path
```    

return the hash of the ressource identified by its path

ex : 

```json
  GET /ressources/home/temperature
  
  { "name" : "/home/temperature",
    "interfaces" : {
      "analog.sensor.temperature.celcuis" : ["read"],
      "analog.sensor.temperature.farenheit" : ["read"],
      "analog.sensor.temperature.kelvin" : ["read"]
    }
  }
```

To access to a particular ressource on a given interface, just proceed like this:

```http
  GET /ressources/ressource_path?iface=iface_name
```

example: 

```json
  GET /ressources/home/temperature?iface=analog.sensor.temperature.celcuis
  
  { "value" : 22.000000 } 
```

```http
  POST /ressources/ressource_path?iface=iface_name&value=value_to_write
```

This will write "value_to_write" to an iface called "iface_name". value_to_write is a string in JSON format.

example: writing 0.5 to the iface analog.order.dimmer of the ressource /home/fan

```json
  POST /ressources/home/fan?iface=analog.order.dimmer&value=[0.5]
  
  { "status" : 0 } 
```

### OAuth2 api ###
