#!/usr/bin/env ruby


require 'pi_piper'


 #expeimental motor testing
motorpin = PiPiper::Pin.new(:pin => 4, :direction => :out)
valvepin = PiPiper::Pin.new( :pin =>17, :direction => :out)

print "\nSeconds ->"
  seconds = STDIN.gets.chomp
  print "\nValveOpen sec ->"
  valvesec = STDIN.gets.chomp
  if seconds =~ /\A[-+]?[0-9]*\.?[0-9]+\Z/
  puts "Test starts for pumping #{seconds} seconds "
  (1..10).each do |i|
  motorpin.on
  sleep seconds.to_f
  motorpin.off
  sleep 1
  valvepin.on
  sleep valvesec.to_f
  valvepin.off
  sleep 1 
 end
end
