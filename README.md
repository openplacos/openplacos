# OpenplacOS: Home automation for your system # [![Build Status](https://secure.travis-ci.org/openplacos/openplacos.png?branch=unstable)](http://travis-ci.org/openplacos/openplacos)


## Presentation ##

Openplacos is an open source project for home automation, aquariophily and indoor gardens that runs on Linux. Source code is licensed under GPLv3.

Openplacos is a project to make possible and easy to extend your computer to new devices. Openplacos is designed for people who want to build their own DIY home automation system. Openplacos is highly flexible and easy to configure

Openplacos gives you the control of your system through a core-server. This core-server can be extended with plugins for more controbality, here is a list of features supported:

* Embedded webserver: control your placos through a website
* Extensibilty: easy to extend to new features and new devices
* SQL support: track your placos into a database
* commmand-line client to easily script your server
* Automated regulations: let your placos control yours actuators to a targetted sensor value. PWM regulations are supported!
 

### How does OpenplacOS work, what do I need to start with ? ###

To use OpenplacOS for an home automation system, you will need some typical hardware:

#### A computer ####

![](http://openplacos.tuxfamily.org/tiki-download_file.php?fileId=4&display&max=200)First of all, you need a *computer* to host the OpenplacOS server. You can use an old one, or buy a Single Board Computer? for a lower power consummation. This computer need to run under a GNU/linux operating system. currently, only Debian, Ubuntu and Gentoo are supported.

The minimum requirement system can vary according to your GNU/Linux distribution. However we recommend you to have at least 256 Mb RAM to run openplacos properly.
OpenplacOS is an automation software to easily control the system you build. OpenplacOS lets you configure a system that represents your system by letting you assemble components that drive your system.

#### An IO Board ####

![](http://openplacos.tuxfamily.org/tiki-download_file.php?fileId=5&display&max=150)Then, you need to interface your hardware with the computer. Basically, OpenplacOS use an Input/Ouput (IO) card. The IO card will get the value of your sensors and redirect orders to your actuators. You can have name of supported IO card, for example you can use an [Arduino](http://www.arduino.cc/) card. You can also use sensors that connect directly on an USB port, for instance the Phidgets sensors

#### Sensors and Actuators ####

![](http://openplacos.tuxfamily.org/tiki-download_file.php?fileId=6&display&max=150)Finally, you need *sensors* and *actuators* to be managed. OpenplacOS is designed to be compatible with as many devices as possible. You can either buy plug&play devices, hack commercial ones or build your own. 

With the high hardware abstraction layer provided by the openplacos-core server, you can access the value of your sensors and control your actuators easily and remotly.

![](http://openplacos.tuxfamily.org/tiki-download_file.php?fileId=7&display&max=500)

## Installation ##

OpenplacOS installation is distribution dependant. Here is a list of distros and corresponding documentation for installing it. 

* ubuntu: ???
* gentoo: ???
* arch: ???

## Data organization ##

Let's start with some definitions:

A component is something physical you plug on your system: it can be an IO card (ex: arduino, µchameleon), sensor (ex: light, temperature)), actuator (relay, pwm driver). OpenplacOS is generic at this point. A component do not have to be categorized as a sensor or an actuator to work. OpenplacOS just consider components and let you put in a "component" whatever you want. 


OpenplacOS organizes ressources using *object* and *interface*. 

* object: An object is a ressource identified by a *path*. This can be */home/temperature*. You can group several objects in something call *room* using the same prefix. For example, */home/temperature* and */home/light* are in the same room: */home/*. This can be usefull for permission managment. An object has several *interfaces*
* interface: An interface is a way to access to a ressource. For example, */home/temperature* can have 2 interfaces: *analog.sensor.temperature.celcuis* *analog.sensor.temperature.farenheit* depending of the unit you want to express your object. There is several kind of interfaces: to control switch, regulation; to express physical metrics, and so on. An interface can be accessed with read write functions. Interfaces can be reused in differents objects.


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

```YAML
- /home/wall/temperature
```

With such export declaration, OpenplacOS will let you control and access to my system with these object temperature.

### Mapping phase ###
At this last part, you will map your components and your export objects together. This mapping will reflect how you have plugged your components into themselves.

To do so, just proceed as described in this example:

```YAML
- /home/wall/temperature: /temperature/temperature
- /temperature/raw: /arduino/Analog0
```

*/home/wall/temperature* is an export object we already declared. It is plugged on */temperature* component on its *temperature* pin. The *raw* pin of */temperature* component is plugged on *Analog0* of */arduino* component.

With this example, we have construct a config for a system that has a temperature sensor plugged on an arduino board.

## OAuth ##

OAuth2 is a protocol dedicated to user authentication. It relies on a central server that can authentify users. External applications that want to authentify an user with oauth2 can based their authentification on the central one. Oauth2 can also manage permissions on a ressource information. This is basically what you do when you go on Facebook and when you have "Do you allow application XXXX to access to your profile, your photos and all your life ?"

All clients that can connect to OpenplacOS server must use OAuth2.0 to manage user authentification. That's why you will have to allow applications to connect to your openplacOS data. To do so, openplacOS embeds a little webserver to let you manage applications permissions and your user profiles. 

## Launch your server ##

OpenplacOS comes with a startup script placed in your init directory. This path depend of your distro. Usually, it is under */etc/init.d/*. Just do 
```
/etc/init.d/openplacos start
```
 to launch it.

## Start talking to OpenplacOS ##

There is several ways to connect to your server.

### Command-line client ###

OpenplacOS comes with a command-line client. If you need to have to this client standalone installed, it will be packaged in a distinct package (not done yet). To run it, do: 
```
$ openplacos -h *host_ip*:4567
```
 Follow instruction to autorize this client. Then you will have a prompt. 

Type:

* `help` to list all commands supported
* `status` to have a top level report of your system
* `list` to have all objects and corresponding interfaces
* `get <object> <iface>` to make a read access on specified object and interface
* `set <object> <iface> <value>` to set an interface of an object to a specified value.
