#!/usr/bin/env ruby
#
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
#    Driver interface test avec sortie en ncurses
#   


require 'dbus'
require 'ncurses'

class CursesTestDriver < DBus::Object

    def initialize(path, service) 
    
        super(path)
        # on init qq pins
        @pins=[]
        (0..7).each do |i|
            @pins[i] = TestPin.new("/org/openplacos/drivers/test/pin/%s" % i, i)
            service.export(@pins[i])
        end    
    end
    
    dbus_interface "org.openplacos.drivers.test" do
     dbus_method :description, "out outstr:s" do
        "OpenplacOs Test Driver"
     end
    end
    
end


class TestPin < DBus::Object

    def initialize( path, index)
        super(path)
        @index = index
        @state = (index%2 == 0) ? true : false
        @desc = "Pin #{index}"
    end
    
    dbus_interface "org.openplacos.api" do
     dbus_method :read, "out outstr:b" do
        @state
     end
    end
    
    def write(value)
        @state = value
    end

end

class CursesInterface
    
    def initialize
        # init de la lib
        @stdscr = Ncurses.initscr
        # init des couleurs
        Ncurses.start_color
        Ncurses.init_pair(1, Ncurses::COLOR_WHITE, Ncurses::COLOR_BLUE)
        Ncurses.init_pair(2, Ncurses::COLOR_WHITE, Ncurses::COLOR_BLACK)
        Ncurses.init_pair(3, Ncurses::COLOR_WHITE, Ncurses::COLOR_GREEN)
        Ncurses.init_pair(4, Ncurses::COLOR_WHITE, Ncurses::COLOR_RED)

        # Supprime l'echo local
        Ncurses.noecho
        # Cache le curseur
        Ncurses.curs_set(0)
        # active les touches F1..F12
        Ncurses.keypad(@stdscr,TRUE)
        # Passe en mode capture/caractère
        Ncurses.cbreak

        # Les dimensions du terminal
        @maxy=Ncurses.getmaxy(@stdscr);
        @maxx=Ncurses.getmaxx(@stdscr);

        # On colorie la fenetre mere
        @stdscr.bkgd(Ncurses.COLOR_PAIR(0))

        # Fenêtre d'Etat
        @win_etat = Ncurses::WINDOW.new(@maxy - 8, @maxx, 0, 0)
        @win_etat.bkgd(Ncurses.COLOR_PAIR(1))
        Ncurses.box(@win_etat,Ncurses::ACS_VLINE,Ncurses::ACS_HLINE)

        # Fenêtre des Evenements
        @win_events = Ncurses::WINDOW.new(5, @maxx, @maxy - 8, 0)
        @win_events.bkgd(Ncurses.COLOR_PAIR(1))
        Ncurses.box(@win_events,Ncurses::ACS_VLINE,Ncurses::ACS_HLINE)

        # Fenêtre de commande
        @win_cmd = Ncurses::WINDOW.new(3, @maxx, @maxy - 3, 0)
        @win_cmd.bkgd(Ncurses.COLOR_PAIR(1))
        Ncurses.box(@win_cmd,Ncurses::ACS_VLINE,Ncurses::ACS_HLINE)

        Ncurses.mvwaddstr(@win_cmd, 1, 1, "[F3] Exit - [F4] Yop - [F5] Refresh ")
        Ncurses.echo

        @stdscr.refresh
        @win_etat.refresh
        @win_events.refresh
        @win_cmd.refresh

    end
    
    def refresh
        @win_etat.attron( Ncurses.COLOR_PAIR(1))
        Ncurses.mvwaddstr(@win_etat, 1, 1, Time.now.strftime("[ %d/%m/%Y - %H:%M:%S ]") )
        @win_etat.attroff( Ncurses.COLOR_PAIR(1))
        @stdscr.refresh
    end
    
    def draw_outputs
        @pins.each do |pin|
            Ncurses.mvwaddstr(@win_etat, pin.index,2, "%s : " % pin.description)
            if pin.state
                @win_etat.attron(Ncurses.COLOR_PAIR(3))
                Ncurses.waddstr(@win_etat," ON")
            else
                @win_etat.attron(Ncurses.COLOR_PAIR(4))
                Ncurses.waddstr(@win_etat, "OFF")
            end
            @win_etat.attroff( Ncurses.COLOR_PAIR(1))
        end
        @win_etat.refresh        
    end
    
    
    def run
        key = 0
        while key != Ncurses::KEY_F3
            key=@stdscr.getch
            if key == Ncurses::KEY_F5
		        # La gestion de l'interface
		        self.refresh
		        
	        elsif key == Ncurses::KEY_F4
		        puts "yop!"
	        end
        end
        # on quitte properment
        Ncurses.delwin(@win_cmd)
        Ncurses.delwin(@win_events)
        Ncurses.delwin(@win_etat)
        Ncurses.endwin
    end
    
end

Thread.new do
    
end

bus = DBus::SessionBus.instance
service = bus.request_service("org.openplacos.drivers.test")
driver = CursesTestDriver.new("/org/openplacos/drivers/test", service)
service.export(driver)
puts "listening"
main = DBus::Main.new
main << bus
main.run


curses=CursesInterface.new()
curses.run
