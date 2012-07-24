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

require 'Event_handler'

class Globals

  # Print trace when debug env var defined
  # string is the message to be traced
  # level is Logger level:  Logger::FATAL; Logger::ERROR; Logger::WARN; Logger::INFO; Logger::DEBUG
  # refers to this http://www.ruby-doc.org/stdlib-1.9.3/libdoc/logger/rdoc/Logger.html
  def self.trace(string_, level_=Logger::WARN)
    if ENV['VERBOSE_OPOS'] != nil
      puts string_
    end
    Top.instance.log.add(level_, string_)
  end

  def self.error(string_,code_ = 255)
    puts "Error:: " + string_
    STDOUT.flush
    
    Top.instance.log.add(Logger::FATAL, string_)
    eh = Event_Handler.instance
    # eh.error(string_) # Does not work ... :-/

    Top.instance.quit # not suffisant but enough for quitting forked components
    Process.exit code_
  end
  
  # Error before top was created
  def self.error_before_start(string_,log_,code_ = 255)
    puts "Error:: " + string_
    STDOUT.flush
    
    log_.add(Logger::FATAL, string_)
    Process.exit code_
  end
end
