#!/usr/bin/perl

#    This file is part of Openplacos.
#
#    Openplacos is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#   the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    Openplacos is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with Openplacos.  If not, see <http://www.gnu.org/licenses/>.
#

use strict;

use Carp qw(confess cluck);
use Net::DBus;
use Net::DBus::Service;
use Net::DBus::Reactor;

package Driver_uCham;

use base qw(Net::DBus::Object);
use Net::DBus::Exporter qw(org.openplacos.driver.uChamInterface);


sub new {
    my $class = shift;
    my $service = shift;
    my $self = $class->SUPER::new($service, "/Driver_uCham");
    bless $self, $class;
    
    return $self;
}

dbus_method("HelloWorld", ["string"], [["array", "string"]]);
sub HelloWorld {
    my $self = shift;
    my $message = shift;
    print "Do hello world, dbus rox sa mere\n";
    print $message, "\n";
    return ["Hello", " from driver_uCham"];
}




package main;

my $bus = Net::DBus->session();
my $service = $bus->export_service("org.openplacos.drivers.uChameleon");
my $object = Driver_uCham->new($service);

Net::DBus::Reactor->main->run();
