#!/usr/bin/env ruby

require 'fifo.rb'

pipe_r = Fifo.new('/tmp/arduino_in')
pipe_w = Fifo.new('/tmp/arduino_out')

# Here is spec for our implementation of arduino
# Command	id	Parameters	Return	Example
# Set pin Mode	4	pin mode	nothing	4 13 out;
# Digital write	5	pin value	nothing	5 13 high;
# Digital read	6	pin	6 pin value	6 13; => 6 13 1
# Analog Read	7	pin	7 pin value	7 2; => 7 2 456.00
# Pwm Write	8	pin value	nothing	8 3 102;
# RCswitch write9	pin code	nothing	9 11 FFFFF0FFFF0F;
# DHt11 Read	10	pin	10 pin humidity temperature	10 3; => 10 3 68.00 22.00

count_255 = 0
count_6   = 0
count_7   = 0

while line = pipe_r.gets
  line.gsub!(';','')
  array = line.split

  case array.first

  when "6"
    pipe_w.write(array.join(" ") + " 1 \n")
   
  when "7"
    pipe_w.write(array.join(" ") + " #{1024/5*3} \n") # return 3 Volts
    
  when "255" 
    count_255 += 1
    if (count_255 == 5)
      count_255 = 0
      pipe_w.write("YEAH \n")
    end
    
  end
end

