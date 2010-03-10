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

package pin_uCham;

use base qw(Net::DBus::Object);
use Net::DBus::Exporter qw(org.openplacos.driver.uChamInterface);

sub new {
    my $class = shift;
    my $service = shift;
    my $Dbus_pin = shift;
    my $self = $class->SUPER::new($service, "/pin_$Dbus_pin");
    bless $self, $class;
    
    return $self;
}

dbus_method("Init", ["bool", "string"], ["bool"]); 
sub Init {
    my $self = shift;
    my $In_out = shift; # Arg1 : is read (=0) or outputwrite (=1)
    my $pin_type = shift; # Arg2 :"analog" "digital" "pwm"
    
    if ($In_out ==0){
	dbus_method("Read", [], ["int"]); 
    }else{
	dbus_method("Write", ["int"], []); 	
    }
    
    return ["1"];
}

sub Read {
    my $self = shift;
    return["2"];
}

sub Write {
    my $self = shift;
    my $arg =shift;
}

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
my @pin = ();

for (my $i = 0; $i<8 ; $i++){
    $pin[$i] = pin_uCham->new($service, $i);
}

Net::DBus::Reactor->main->run();
