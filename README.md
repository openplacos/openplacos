# OpenplacOS: Home automation for your system #

OpenplacOS is an automation software to easily control the system you build. OpenplacOS lets you configure a system that represents your system by letting you assemble components that drive your system.

A component is something physical you plug on your system: it can be an IO card (ex: arduino, µchameleon), sensor (ex: light, temperature)), actuator (relay, pwm driver). OpenplacOS is generic at this point. A component do not have to be categorized as a sensor or an actuator to work. OpenplacOS just consider components and let you put in a "component" whatever you want. 

## Installation ##

OpenplacOS installation is distribution dependant. Here is a list of distros and corresponding documentation for installing it. 

* ubuntu: ???
* gentoo: ???
* arch: ???

## Data organization ##

OpenplacOS organizes ressources using *object* and *interface*. 

* object: An object is a ressource identified by a *path*. This can be /home/temperature. You can group several objects in something call *room* using the same prefix. For example, /home/temperature and /home/light are in the same room: /home/. This can be usefull for permission managment. An object has several *interfaces*
* interface: An interface is a way to access to a ressource. For example, /home/temperature can have 2 interfaces: *analog.sensor.temperature.celcuis* *analog.sensor.temperature.farenheit* depending of the unit you want to express your object. There is several kind of interfaces: to control switch, regulation; to express physical metrics, and so on. An interface can be accessed with read write functions. Interfaces can be reused in differents objects.


## Config file ##

OpenplacOS config file is quite easy to set up. This file is basically in yaml and is composed in 3 parts:

### Component declaration ###
In this first part, you will describe all components you want to use by setting attributes like this: 

```YAML
- name: arduino
  exec: arduino.rb
  method: fork
  config:
    port: /dev/ttyACM0

- name: temperature
  exec: temperature_compact.rb
  method: fork
```

* name: the name of the component. Used next to identy this component.
* exec: path to executable to run to launch this component.
* method: [fork/thread/debug/disable]. Use fork to run this component as an external process, thread as a thread of server. Use debug when a problem occurs when launching this component. 
* config: this attributes is usefull to pass arguments to component. config must contains a hash.



### Export list ###
In this part, list some objects as you want to be your top-level system control. For example, if you want to manage a heater regulation, you want to have a thermostat being you top level control system.

At this step, just list your controls such as:
- /home/wall/temperature

With such export declaration, OpenplacOS will let you control and access to my system with these object temperature.

### Mapping phase ###
At this last part, you will map your components and your export objects together. This mapping will reflect how you have plugged your components into themselves.

To do so, just proceed as described in this example:
- /home/wall/temperature: /temperature/temperature
- /temperature/raw: /arduino/Analog0

/home/wall/temperature is an export object we already declared. It is plugged on /temperature component on its "temperature" pin. The "raw" pin of /temperature component is plugged on "Analog0" of arduino component.

With this example, we have construct a config for a system that has a temperature sensor plugged on an arduino board.

## OAuth ##

OAuth2 is a protocol dedicated to user authentication. It relies on a central server that can authentify users. External applications that want to authentify an user with oauth2 can based their authentification on the central one. Oauth2 can also manage permissions on a ressource information. This is basically what you do when you go on Facebook and when you have "Do you allow application XXXX to access to your profile, your photos and all your life ?"

All clients that can connect to OpenplacOS server must use OAuth2.0 to manage user authentification. That's why you will have to allow applications to connect to your openplacOS data. To do so, openplacOS embeds a little webserver to let you manage applications permissions and your user profiles. 

## Launch your server ##

OpenplacOS comes with a startup script placed in your init directory. This path depend of your distro. Usually, it is under /etc/init.d/. Just do #`/etc/init.d/openplacos start` to launch it.

## Start talking to OpenplacOS ##

There is several ways to connect to your server.

### Command-line client ###

OpenplacOS comes with a command-line client. If you need to have to this client standalone installed, it will be packaged in a distinct package (not done yet). To run it, do: $`openplacos -h *host_ip*:4567`. Follow instruction to autorize this client. Then you will have a prompt. 

Type:

* `help` to list all commands supported
* `status` to have a top level report of your system
* `list` to have all objects and corresponding interfaces
* `get <object> <iface>` to make a read access on specified object and interface
* `set <object> <iface> <value>` to set an interface of an object to a specified value.