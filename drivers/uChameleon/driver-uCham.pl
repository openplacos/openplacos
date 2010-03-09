#!/usr/bin/perl

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
    print "Do hello world\n";
    print $message, "\n";
    return ["Hello", " from driver_uCham"];
}




package main;

my $bus = Net::DBus->session();
my $service = $bus->export_service("org.openplacos.drivers.uChameleon");
my $object = Driver_uCham->new($service);

Net::DBus::Reactor->main->run();
