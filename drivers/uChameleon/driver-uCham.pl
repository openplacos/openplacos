#!/usr/bin/perl

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
#

use strict;
use warnings;

use Carp qw(confess cluck);
use Net::DBus;
use Net::DBus::Service;
use Net::DBus::Reactor;

require 'dbus_ifaces.pl';
require 'pin_uCham.pl';
require 'pin_uCham_analog.pl';
require 'pin_uCham_pwm.pl';



package Driver_uCham;

#dbus
use base qw(Net::DBus::Object);
use Net::DBus::Exporter qw(org.openplacos.driver.uChamInterface);

#rs232
use lib './blib/lib','../blib/lib'; # can run from here or distribution base
use Device::SerialPort;
use strict;



sub new {
    my $class = shift;
    my $service = shift;
    my $file = shift;

    # Setting up RS232 connection
    my $ob = Device::SerialPort->new ($file) || die "Can't open $file: $!";
    $ob->baudrate(9600)	|| die "fail setting baudrate";
    $ob->parity("none")	|| die "fail setting parity";
    $ob->databits(8)	|| die "fail setting databits";
    $ob->stopbits(1)	|| die "fail setting stopbits";

    $ob->write_settings || die "no settings";

    $ob->error_msg(1);		# use built-in error messages
    $ob->user_msg(1);
    $ob->read_char_time(0);     # don't wait for each character
    $ob->read_const_time(100);  # 100 milliseconds per unfulfilled "read" call

    my $self =  $class->SUPER::new($service, "/Driver_uCham");
    $self->{rs232_file} =  $file;
    $self->{Serialport} = $ob;

    bless $self, $class;

    return $self;
}

sub send_message {
    my $self = shift;
    my $message = shift;

    my $ob =  $self->{Serialport};

    return  $ob->write("$message\n");
} 

sub read_message {
    my $self = shift;
    my $length = shift;

    my $ob =  $self->{Serialport};

    return  $ob->read($length);
} 




package main;

my $file = "/dev/ttyUSB0";

my $bus = Net::DBus->session();
my $service = $bus->export_service("org.openplacos.drivers.uchameleon");
my $object = Driver_uCham->new($service, $file);
my @pin = ();

$object->send_message("led off");

print ( "debug !!!!!");

# Led is considered as pin 0
$pin[0]=pin_uCham_analog->new($service, 0, $object, 0, 0, 0, 0);

for (my $i = 1; $i<=8 ; $i++){
    # Dbus service, pin_number, RS232 connection, is_analog_in, is_pwm_out, is_spi, is_UART
    $pin[$i] = pin_uCham_analog->new($service, $i, $object, 1, 0, 0, 0); # analog
}

for (my $i = 9; $i<=12 ; $i++){
    $pin[$i] = pin_uCham_pwm->new($service, $i, $object, 0, 1, 0, 0); # pwm
}

for (my $i = 13; $i<=16 ; $i++){
    $pin[$i] = pin_uCham->new($service, $i, $object, 0, 0, 1, 0); # spi
}

for (my $i = 17; $i<=18 ; $i++){
    $pin[$i] = pin_uCham->new($service, $i, $object, 0, 0, 0, 1); # UART
}


Net::DBus::Reactor->main->run();
