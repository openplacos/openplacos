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
    my $pin_number = shift;
    my $card = shift;
    my $is_analog_in = shift;
    my $is_pwm_out = shift;
    my $is_spi = shift; 
    my $is_UART = shift;
    
    my $pin_name;
    my $self ;

    if ($pin_number == 0) {
	$pin_name = "led";
	$self = $class->SUPER::new($service, "/led");
    }else{
	$pin_name = "pin $pin_number";
	$self = $class->SUPER::new($service, "/pin_$pin_number");
    }

    bless $self, $class; 
    
    $self->{ref_io_pin} = 1;
    $self->{pin_name} = $pin_name;
    $self->{pin_number} = $pin_number;
    $self->{card} =  $card;
    $self->{is_analog_in} =  $is_analog_in;
    $self->{is_pwm_out} =  $is_pwm_out;
    $self->{is_pwm_init} = 0;
    $self->{is_spi} =  $is_spi;
    $self->{is_UART} =  $is_UART;
    
     
    return $self;
}

dbus_method("Read", [], ["string"]);
sub Read_analog {
    my $self = shift;
    my $io_pin = $self->{ref_io_pin};
    my $pin_name =  $self->{pin_name};
    my $pin_number =  $self->{pin_number};
    my $card = $self->{card};

    # Not an analogic input
    if ($self->{is_analog_in} != 1){
	return "Cannot read analog input on $pin_name";
    }

    # Change pin IO to input
    if ($io_pin == 1){
	$card->send_message("$pin_name input ")  || die "Failed to set $pin_name input";
	$io_pin = 0;
    }

    # Turn off PWM
    if ($self->{is_pwm_init} == 1 && $self->{is_pwm_out} == 1){
        $card->send_message("pwn $pin_number off")           || die "Failed to set PWM OFF on $pin_name";
	$self->{is_pwm_init} = 0;
    }

    # Read access
    return $card->send_message("$pin_name state")  || die "Failed to read on boolean $pin_name in";
    
}


dbus_method("Read_b", [], ["bool"]);
sub Read_b {
    my $self = shift;
    my $io_pin = $self->{ref_io_pin};
    my $pin_name =  $self->{pin_name};
    my $pin_number =  $self->{pin_num};
    my $card = $self->{card};

    # Led cannot read
    if ($pin_number == 0){
	return "Led cannot support read";
    }

    # Change pin IO to input   
    if ($io_pin == 1){ 
	$card->send_message("$pin_name input ")  || die "Failed to set analog $pin_name input";
	$io_pin = 0;
    }

    # Turn off PWM
    if ($self->{is_pwm_init} == 1 && $self->{is_pwm_out} == 1){
        $card->send_message("pwn $pin_number off")           || die "Failed to set PWM OFF on $pin_name";
	$self->{is_pwm_init} = 0;
    }

    # Read access
    return $card->send_message("adc $pin_number")  || die "Failed to read on $pin_name in";
}

dbus_method("Write_b", ["bool"], []); 	
sub Write_b {
    my $self = shift;
    my $arg =shift;
    my $io_pin = $self->{ref_io_pin};
    my $pin_name =  $self->{pin_name};
    my $pin_number =  $self->{pin_number};
    my $card = $self->{card};

    # Convert to an affordable value
    my $pwm_arg;
    if ($arg){
	if ($pin_number == 0){
	    $pwm_arg = "on"; 
	    }else{
		$pwm_arg = "high"; 
	    }
    }else{
	if ($pin_number == 0){
	    $pwm_arg = "off"; 
	}else{
	    $pwm_arg = "low"; 
	    }
    }

    # Change pin IO to output
    if ($io_pin == 0){ 
	$self->{card}->send_message("$pin_name output");
	$io_pin = 1;
    }

    # Turn off PWM
    if ($self->{is_pwm_init} == 1 && $self->{is_pwm_out} == 1){
        $card->send_message("pwn $pin_number off")           || die "Failed to set PWM OFF on $pin_name";
	$self->{is_pwm_init} = 0;
    }
    
    # Write access
    return $card->send_message("$pin_name $pwm_arg")  || die "Failed to set $pwm_arg $pin_name output";
}

dbus_method("Write_pwm", ["bool"], []); 	
sub Write_pwm {
    my $self = shift;
    my $arg =shift;
    my $io_pin = $self->{ref_io_pin};
    my $pin_name =  $self->{pin_name};
    my $pin_number =  $self->{pin_number};
    my $is_pwm_init =  $self->{is_pwm_init};
    my $card = $self->{card};

    # This is a wild world
    my $int_arg = int($arg || 0);

    # Convert to an affordable value
    my $pwm_arg = int( (1000/5) * $int_arg); 

    # Not an analogic output
    if ($self->{is_pwm_out} != 1){
	return "Cannot generate PWM output on $pin_name";
    }
    
    # Change pin IO to output
    if ($io_pin == 0){ 
	$self->{card}->send_message("$pin_name output");
	$io_pin = 1;
    }

    # Init PWM
    if ($is_pwm_init == 0){
	$card->send_message("pwn $pin_number period 1000")  || die "Failed to set PWM frequency on $pin_name";
	$card->send_message("pwn $pin_number polarity 0")   || die "Failed to set PWM polarity on $pin_name";
        $card->send_message("pwn $pin_number on")           || die "Failed to set PWM ON on $pin_name";
	$is_pwm_init = 1;
    }
    
    # Write access
    return $card->send_message("pwm $pin_number $pwm_arg")  || die "Failed to set $pwm_arg PWM on $pin_name";
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

# Led is considered as pin 0
$pin[0]=pin_uCham->new($service, 0, $object, 0, 0, 0, 0);

for (my $i = 1; $i<=8 ; $i++){
    # Dbus service, pin_number, RS232 connection, is_analog_in, is_pwm_out, is_spi, is_UART
    $pin[$i] = pin_uCham->new($service, $i, $object, 1, 0, 0, 0);
}

for (my $i = 9; $i<=12 ; $i++){
    $pin[$i] = pin_uCham->new($service, $i, $object, 0, 1, 0, 0);
}

for (my $i = 13; $i<=16 ; $i++){
    $pin[$i] = pin_uCham->new($service, $i, $object, 0, 0, 1, 0);
}

for (my $i = 17; $i<=18 ; $i++){
    $pin[$i] = pin_uCham->new($service, $i, $object, 0, 0, 0, 1);
}


Net::DBus::Reactor->main->run();
