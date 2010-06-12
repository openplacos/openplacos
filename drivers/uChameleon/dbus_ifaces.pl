#/usr/bin/perl

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



package dbus_analog;

use base qw(Net::DBus::Object);
use Net::DBus::Exporter qw(org.openplacos.driver.uChamInterface);

use base 'Class::Accessor';
__PACKAGE__->mk_accessors(
	qw(
		counter
	)
);

dbus_method("read_analog", [["dict", "string", ["variant"]]], [["variant"]], "org.openplacos.driver.analog");
sub read_analog {
    my $self = shift;
    my $pin = $self->{pin};
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
	 $self->{ref_io_pin} = 0;
    }

    # Turn off PWM
    if ($self->{is_pwm_init} == 1 && $self->{is_pwm_out} == 1){
        $card->send_message("pwm $pin_number off")           || die "Failed to set PWM OFF on $pin_name";
	$self->{is_pwm_init} = 0;
    }

    # Command read access
    $card->send_message("adc $pin_number")  || die "Failed to read on analog $pin_name";

    # Get access
    my $result = $card->read_message(255);

    # Processing result
    if ( $result =~ m/adc $pin_number\s*(\d+)/){
	$result = $1;
	$result = ($result)/255 
    }

   return $result;
}

package dbus_digital;

use base qw(Net::DBus::Object);
use Net::DBus::Exporter qw(org.openplacos.driver.digital);

use base 'Class::Accessor';
__PACKAGE__->mk_accessors(
	qw(
		counter
	)
);

dbus_method("read_digital", [["dict", "string", ["variant"]]], [["variant"]], ["bool"]);
sub read_digital {
    my $self = shift;
    my $io_pin = $self->{ref_io_pin};
    my $pin_name =  $self->{pin_name};
    my $pin_number =  $self->{pin_number};
    my $card = $self->{card};

    # Led cannot read
    if ($pin_number == 0){
	return "Led cannot support read";
    }

    # Change pin IO to input   
    if ($io_pin == 1){ 
	$card->send_message("$pin_name input ")  || die "Failed to set analog $pin_name input";
	$self->{ref_io_pin} = 0;
    }

    # Turn off PWM
    if ($self->{is_pwm_init} == 1 && $self->{is_pwm_out} == 1){
        $card->send_message("pwm $pin_number off")           || die "Failed to set PWM OFF on $pin_name";
	$self->{is_pwm_init} = 0;
    }

    # Command read access
    $card->send_message("pin $pin_number state")  || die "Failed to read on $pin_name in";
 
    # Get access
    my $result = $card->read_message(255);

   # Processing result
    if ( $result =~ m/$pin_name\s*(\d)/){
	$result = $1;
    }

    return $result;
}

dbus_method("write_digital", ["bool", ["dict", "string", ["variant"]]], [["variant"]], []); 	
sub write_digital {
    my $self = shift;
    my $arg =shift;
    my $io_pin = $self->{ref_io_pin};
    my $pin_name =  $self->{pin_name};
    my $pin_number =  $self->{pin_number};
    my $card = $self->{card};

    # Convert to an affordable value
    my $bool_arg;
    if ($arg){
	if ($pin_number == 0){
	    $bool_arg = "on"; 
	}else{
	    $bool_arg = "high"; 
	}
    }else{
	if ($pin_number == 0){
	    $bool_arg = "off"; 
	}else{
	    $bool_arg = "low"; 
	}
    }

    # Change pin IO to output
    if ($io_pin == 0){ 
	$self->{card}->send_message("$pin_name output");
	$self->{ref_io_pin} = 1;
    }

    # Turn off PWM
    if ($self->{is_pwm_init} == 1 && $self->{is_pwm_out} == 1){
        $card->send_message("pwm $pin_number off")           || die "Failed to set PWM OFF on $pin_name";
	$self->{is_pwm_init} = 0;
    }
    
    # Write access
    return $card->send_message("$pin_name $bool_arg")  || die "Failed to set $bool_arg $pin_name output";
}

package dbus_pwm;

use base qw(Net::DBus::Object);
use Net::DBus::Exporter qw(org.openplacos.driver.pwm);

use base 'Class::Accessor';
__PACKAGE__->mk_accessors(
	qw(
		counter
	)
);

dbus_method("write_pwm", ["double", ["dict", "string", ["variant"]]], [["variant"]], []); 	
sub write_pwm {
    my $self = shift;
    my $arg =shift;
    my $io_pin = $self->{ref_io_pin};
    my $pin_name =  $self->{pin_name};
    my $pin_number =  $self->{pin_number};
    my $is_pwm_init =  $self->{is_pwm_init};
    my $card = $self->{card};

    # Convert to an affordable value
    my $pwm_arg =  (1000/5) * $arg;

    # Not an analogic output
    if ($self->{is_pwm_out} != 1){
	return "Cannot generate PWM output on $pin_name";
    }
    
    # Change pin IO to output
    if ($io_pin == 0){ 
	$self->{card}->send_message("$pin_name output");
	$self->{ref_io_pin} = 1;
    }

    # Init PWM
    if ($is_pwm_init == 0){
	$card->send_message("pwm $pin_number period 1000")  || die "Failed to set PWM frequency on $pin_name";
	$card->send_message("pwm $pin_number polarity 0")   || die "Failed to set PWM polarity on $pin_name";
        $card->send_message("pwm $pin_number on")           || die "Failed to set PWM ON on $pin_name";
	$self->{is_pwm_init} = 1;
    }
    
    # Write access
    return $card->send_message("pwm $pin_number width $pwm_arg") || die "Failed to set $pwm_arg PWM on $pin_name";
}
