#!/usr/bin/env ruby

require 'time'
require 'typhoeus'
require 'typhoeus/adapters/faraday'
require 'elasticsearch'
require 'pi_piper'

Thread.abort_on_exception = true

#Generating elasticsearch index
es = Elasticsearch::Client.new url: ARGV[0]
index_exists = es.indices.exists index: "motortest-project-index"
if !index_exists
  puts "Index \"motortest-project-index\" does not exist. Creating..."
  es.indices.create index: "motortest-project-index",
      body: {
          settings: {
              number_of_shards: 1
          },
          mappings: {
              sensor_data: {
                  properties: {
                      timestamp: {
                          type: 'date',
                          format: 'epoch_millis',
                          index: 'not_analyzed'
                      },
                      sensor_number: {
                          type: 'integer',
                          index: 'not_analyzed',
                          fields: {
                              raw: {
                                  type: 'keyword'
                              }
                          }
                      },
                      value: {
                          type: 'double',
                          index: 'not_analyzed',
                          fields: {
                              raw: {
                                  type: 'keyword'
                              }
                          }
                      },
                  }
              }
          }
      }, wait_for_active_shards: 1
  puts "Index created."
end

input_valid = false
while !input_valid do
  # Ask for values
  print "\nMotor pump Seconds ->"
  seconds = STDIN.gets.chomp
  print "\nValveOpen sec ->"
  valvesec = STDIN.gets.chomp

  # go into scheduled mode
  if seconds =~ /\A[-+]?[0-9]*\.?[0-9]+\Z/ &&
    valvesec =~ /\A[-+]?[0-9]*\.?[0-9]+\Z/
    puts "Test starts for pumping #{seconds} seconds and valves #{valvesec}"
    input_valid = true
  else
    puts "Invalid input, please try again."
  end
end

puts "Generating data now."
#Threading Sensor readings
sensorthreads = Array.new
flowrate = Array.new
flowsensor_on = true
running = true

(0..0).each do |i|
  sensorthreads[i] = Thread.new do
    while flowsensor_on do
      value = 0
      PiPiper::Spi.begin do |spi|
        raw = spi.write [1, (8 + i) << 4, 0]
        value = ((raw[1] & 3) << 8) + raw[2]
      end
      next if value == 0
      flowrate[i] = value * 500 / 1023.0
      es.index index: 'motortest-project-index',
        type: 'sensor_data',
        body: {
            timestamp: (Time.now.to_f * 1000.0).to_i,
            sensor_number: i,
            value: flowrate[i]
        }
    end
  end
end

# Calibration loop
count = 0
tot = 0
average = 0
variance = 0
stdev = 0
calibrationon = true
readingarray = Array.new

while calibrationon do
  reading = flowrate[0]
  next if reading.nil?
  next if reading <= 0
  puts "Reading is #{reading} at count #{count}"
  # start accumulating an average for proof that
  # we are, in fact, getting consistent flow...
  #
  # we'll use the average to seed our high/low calculations next
  # if count >= 0  && count <= 100
  count += 1
  sleep(0.01)
  next if count <= 250
  tot += reading
  average = tot/(count-250)
  variance = (reading-average)**2/(count-250)
  stdev = Math.sqrt(variance)
  readingarray.push(reading)
  

  if count == 1500
  avgarray = readingarray.uniq.reduce(:+) / readingarray.uniq.size
  puts "Calibrated after 2000 readings...average at #{average} and avgarray #{avgarray} finding systol/diastol cycles..."
end

  if count >= 1500 and count < 3500
    # set up some counters to track what the
    # highest throughput (potential systol) and
    # lowest throughput(potential diastol)  we have seen are
    highest ||= [average]
    lowest ||= [average]
    avg_systol = highest.reduce(:+) / highest.size.to_f
    avg_diastol = lowest.reduce(:+) / lowest.size.to_f
    # Do the actual comparison per loop maybe make it the average
    if reading > avg_systol && stdev < 2 && stdev > -2
      highest.push(reading)
      puts "New high of #{avg_systol} found."
    elsif reading <= avg_diastol && stdev < 2 && stdev > -2
      lowest.push(reading)
      puts "New low of #{avg_diastol} found."
    end
  end

  if count == 3500
    puts "Count is #{count}"
    # Keep the end users busy with some shiny TEXTTT!!!!
    puts "Proceeding with presumed systol of #{avg_systol} and presumed diastol of #{avg_diastol}..."
  end
  if count >= 3500 && count < 5000
    # set up our variables if needed
    systol_duration_total ||= 0
    systol_count ||= 0
    diastol_duration_total ||= 0
    diastol_count ||= 0
    systol_timestamp ||= nil
    diastol_timestamp ||= nil
    state ||= :none

    # figure out if we are nearest to systol (highest) or diastol (lowest)
   # midpoint = (avg_systol + avg_diastol)/2
    
    diff_to_systol = (avg_systol - reading).abs * 1.2
    diff_to_diastol = (avg_diastol - reading).abs
   # if reading <= avg_systol  
   if diff_to_diastol < diff_to_systol
      puts "Reading is in diastol range..."
      # we are diastol!!!
      case state
      when :none
        # we were not running and this is our first time.
        # let's get a timestamp and remember it for later... :)
        diastol_timestamp = DateTime.now
      when :diastol
        # we are _still_ diastol and waiting for the damn pump to switch back over
      when :systol
        # uh-oh!!! this is a time when we have just changed from systol to diastol...
        # let's remember this event too... :)
        diastol_timestamp = DateTime.now
        if !systol_timestamp.nil?
          systol_duration_total += (diastol_timestamp.to_time.to_f - systol_timestamp.to_time.to_f)
          systol_count += 1
        end
      end
      state = :diastol
    elsif diff_to_systol < diff_to_diastol
      puts "Reading is in systol range..."
      # we are systol!!!
      case state
      when :none
        # looks like we started out as systol for the first time.  Coolio :)
        # let's write this down...
        systol_timestamp = DateTime.now
      when :diastol
        # we have freshly changed over from diastol to systol.  This is an event to be remembered.
        systol_timestamp = DateTime.now
        if !diastol_timestamp.nil?
          diastol_duration_total += (systol_timestamp.to_time.to_f - diastol_timestamp.to_time.to_f)
          diastol_count += 1
        end
      when :systol
        # we are still in systol
      end
      state = :systol
    end
    puts "Average systol duration at #{systol_duration_total.to_f / systol_count}s" if systol_count > 0
    puts "Average diastol duration at #{diastol_duration_total.to_f / diastol_count}s" if diastol_count > 0
  end
  calibrationon = false if count > 5000
end

motorpin = PiPiper::Pin.new(:pin => 4, :direction => :out)
valvepin = PiPiper::Pin.new(:pin => 17, :direction => :out)

# Scheduled mode!!!
while true do
  if state == :diastol
    puts "Flipping to diastol..."
    sleep (diastol_duration_total.to_f / diastol_count)
    state = :systol
  elsif state == :systol
       puts "Test starts for pumping #{seconds} seconds "
           motorpin.on
           sleep seconds.to_f
           motorpin.off
           valvepin.on
           sleep valvesec.to_f
          valvepin.off
          sleeptime = (systol_duration_total.to_f / systol_count)-seconds.to_f - valvesec.to_f
    sleep (sleeptime)
    state = :diastol
  end
end
