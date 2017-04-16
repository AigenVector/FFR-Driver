#!/usr/bin/env ruby

require 'elasticsearch'
require 'pi_piper'

#Defining elasticsearch index

es = Elasticsearch::Client.new url: ARGV[0], log: true
index_exists = es.indices.exists index: "test-project-index"
if !index_exists
puts "Index \"test-project-index\" does not exist. Creating..."
es.indices.create index: "test-project-index",
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
puts "Generating data now."

#Threading Sensor readings

sensorthreads = Array.new
flowrate = Array.new
flowsensor_on = true

#Defining when the program should run
running = true
Signal.trap("INT") {
  running = false
  }
# Trap `Kill ` May want to get rid of
Signal.trap("TERM") {
  running = false
  }

(0..2).each do |i |
  sensorthreads[i] = Thread.new do
        while flowsensor_on do
            value = 0
            PiPiper::Spi.begin do |spi |
              raw = spi.write[1, (8 + i) << 4, 0]
              value = ((raw[1] & 3) << 8) + raw[2]
            end
            # input correct algorithm#
            flowrate[i] = value * 500 / 5
      # Generating sensor i
      es.index index: 'test-project-index',
          type: 'sensor_data',
          body: {
              timestamp: (Time.now.to_f * 1000.0).to_i,
              sensor_number: i,
              value: flowrate[i]
                }
            sleep(.25)
      end
  end
end

# Show that we can use the GPIO from teh subprocess
motorpin = PiPiper::Pin.new(: pin => 4, : direction => : out)

while running
  print "\nSeconds ->"
  seconds = gets.to_f
  puts "Test starts for pumping #{seconds} seconds "
  motorpin.on
  sleep seconds
  motorpin.off
end



flowsensor_on = false
sensorthreads.each { | thr | thr.join }
puts "Data generation complete"
