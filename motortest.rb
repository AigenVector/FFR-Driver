#!/usr/bin/env ruby
require 'pi_piper'

valvepin = PiPiper::Pin.new(:pin => 17, :direction => :out)

while true
  print "\nSeconds ->"
  seconds = gets.to_f
  puts "Test starts for pumping #{seconds} seconds "
    valvepin.on
    sleep seconds
    valvepin.off
end
