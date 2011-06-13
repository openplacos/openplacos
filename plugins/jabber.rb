#!/usr/bin/ruby -w

#    This file is part of Openplacos.
#
#    Openplacos is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    Openplacos is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with Openplacos.  If not, see <http://www.gnu.org/licenses/>.
require "rubygems"
require 'xmpp4r/client'
include Jabber
require "openplacos"
require "micro-optparse"

options = Parser.new do |p|
  p.banner = "This is openplacos plugins for jabber communication"
  p.version = "jabber 1.0"
  p.option :login, "the jabber login", :default => "none"
  p.option :password, "the password", :default => "none"
end.process!

plugin = Openplacos::Plugin.new

plugin.nonblock_run

Opos = Openplacos::Client.new

def report
    out = ""
    sensor_list = Opos.sensors
    sensor_list.each_key{ |key|
      out << "#{key}  : %.1f°C\n" % Opos.sensors[key].value
    }
    return out    
end

# Jabber::debug = true # Uncomment this if you want to see what's being sent and received!
jid = JID::new(options[:login])
client = Client.new(jid)
client.connect
client.auth(options[:password])
client.send(Presence.new)
puts "Connected ! send messages to #{jid.strip.to_s}."
Thread.abort_on_exception=true
mainthread = Thread.current
client.add_message_callback do |m|
  if m.type != :error
    case m.body
    when /[Ss]alut/
        message = "Bonjour, maître" 
    when /[Rr]eport/
        message = report
    when /[Mm]erci/
        message = "A votre service, maître"
    when /[Pp]lacos*/
        message = "Oui maître ?"
    when /sensors/
        message = Opos.sensors.keys.sort.join("\n")
    when /actuators/
        message = Opos.actuators.keys.sort.join("\n")
    when /sens de la vie/
        message = "42"
    when /^opos (.*) (.*)/
        ret = Opos.sensors[$1].method($2).call if Opos.sensors[$1]
        ret = Opos.actuators[$1].method($2).call if Opos.actuators[$1]
        message = "%s" % ret
    when /^[Cc]ombien (.*)/
        if Opos.sensors[$1]
            ret = Opos.sensors[$1].value
            message = "%s" % ret
        else
            message = "Je ne connais pas #$1"
        end
    when /^[Aa]llume (.*)/
        if Opos.actuators[$1]
            Opos.actuators[$1].on
            message = "#$1 allumé"
        else
            message = "Je ne connais pas #$1"
        end
    when /^[Ee]teint (.*)/
        if Opos.actuators[$1]
            Opos.actuators[$1].off
            message = "#$1 éteint"
        else
            message = "Je ne connais pas #$1"
        end
    when /[Ee]xit/
        mainthread.wakeup
    end
    m2 = Message.new(m.from, message)
    m2.type = m.type
    client.send(m2)
  end
end
Thread.stop
client.close
