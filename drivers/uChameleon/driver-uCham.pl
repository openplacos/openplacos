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
use warnings;

use Carp qw(confess cluck);
use Net::DBus;
use Net::DBus::Service;
use Net::DBus::Reactor;

package pin_uCham;

use base qw(Net::DBus::Object);
use Net::DBus::Exporter qw(org.openplacos.driver.uChamInterface);

use base 'Class::Accessor';
__PACKAGE__->mk_accessors(
	qw(
		counter
	)
);


sub new {
    my $class = shift;
    my $service = shift;
    my $Dbus_pin = shift;
    my $card = shift;
    my $self = $class->SUPER::new($service, "/pin_$Dbus_pin");
    bless $self, $class;    

    $self->{ref_io_pin} = 1;
    $self->{Dbus_pin} = $Dbus_pin;
    $self->{card} =  $card;
 
    
    return $self;
}

dbus_method("Read", [], ["string"]);
sub Read {
    my $self = shift;
    my $io_pin = $self->{ref_io_pin};
    my $pin =  $self->{Dbus_pin};
    my $card = $self->{card};

    if ($io_pin == 1){
	$card->send_message("pin $pin input ")  || die "Failed to set pin $pin input";
	$io_pin = 0;
    }
    return $card->send_message("pin $pin state")  || die "Failed to read on boolean pin $pin in";
    
}


dbus_method("Read_b", [], ["bool"]);
sub Read_b {
    my $self = shift;
    my $io_pin = $self->{ref_io_pin};
    my $pin =  $self->{Dbus_pin};
    my $card = $self->{card};

    if ($io_pin == 1){ # Change to input
	$card->send_message("pin $pin input ")  || die "Failed to set analog pin $pin input";
	$io_pin = 0;
    }
    return $card->send_message("adc $pin")  || die "Failed to read on pin $pin in";
    
}


dbus_method("Write", ["string"], []); 	
sub Write {
    my $self = shift;
    my $arg =shift;
    my $io_pin = $self->{ref_io_pin};
    my $pin =  $self->{Dbus_pin};
    
    if ($io_pin == 0){ # Change to output
	$self->{card}->send_message("pin $pin output");
	$io_pin = 1;
    }
    
    return $card->send_message("adc $pin")  || die "Failed to read on pin $pin in";
}

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





package main;

my $file = "/dev/ttyUSB0";



my $bus = Net::DBus->session();
my $service = $bus->export_service("org.openplacos.drivers.uChameleon");
my $object = Driver_uCham->new($service, $file);
my @pin = ();

$object->send_message("led off");

for (my $i = 0; $i<8 ; $i++){
    $pin[$i] = pin_uCham->new($service, $i, $object );
}

Net::DBus::Reactor->main->run();
