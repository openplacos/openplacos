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


package pin_uCham;

use base qw(Net::DBus::Object) ;
use Net::DBus::Exporter qw(org.openplacos.driver.uChamInterface);

use base 'Class::Accessor';
__PACKAGE__->mk_accessors(
    qw(
		counter
	)
    );

@pin_uCham::ISA = (@pin_uCham::ISA, qw(dbus_digital)) ;
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
	$self = $class->SUPER::new($service, "/led");
	$pin_name = "led";
    }else{
	$self = $class->SUPER::new($service, "/pin_$pin_number");
	$pin_name = "pin $pin_number";
    }

    if ($pin_number != 0) {
	# Pin input by default
	$card->send_message("$pin_name input")  || die "Failed to set analog $pin_name input";
    }

    $self->{ref_io_pin} = 0;

    $self->{pin_name} = $pin_name;
    $self->{pin_number} = $pin_number;
    $self->{card} =  $card;
    $self->{is_analog_in} =  $is_analog_in;	
    $self->{is_pwm_out} =  $is_pwm_out;
    $self->{is_pwm_init} = 0;
    $self->{is_spi} =  $is_spi;
    $self->{is_UART} =  $is_UART;

    bless $self, $class; 

    
    return $self;
}

