#!/usr/bin/env ruby

require 'elasticsearch'
require 'pi_piper'

#Thread.abort_on_exception =true


#defining elasticsearch index

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
puts "Generating data now."

#Threading Sensor readings

sensorthreads = Array.new
flowrate = Array.new
flowsensor_on = true
running = true

(0..0).each do |i |
  sensorthreads[i] = Thread.new do
        while flowsensor_on do
            value = 0
            PiPiper::Spi.begin do |spi|
              raw = spi.write [1, (8 + i) << 4, 0]
              value = ((raw[1] & 3) << 8) + raw[2]
             # puts "The flowrate value is #{value}"
            end
            # input correct algorithm#
            flowrate[i] = value * 500 / 1023
           # puts "Flowrate for thread #{i} = #{flowrate[i]}"
      # Generating sensor

    next if value ==0
    es.index index: 'motortest-project-index',
          type: 'sensor_data',
          body: {
              timestamp: (Time.now.to_f * 1000.0).to_i,
              sensor_number: i,
              value: flowrate[i]
                }
            sleep(0.25)
     end
  end
end

# Expeimental motor testing
motorpin = PiPiper::Pin.new(:pin => 4, :direction => :out)
valvepin = PiPiper::Pin.new( :pin =>17, :direction => :out)
while running

print "\nSeconds ->"
  seconds = STDIN.gets.chomp
  print "\nValveOpen sec ->"
  valvesec = STDIN.gets.chomp
  if seconds =~ /\A[-+]?[0-9]*\.?[0-9]+\Z/
  puts "Test starts for pumping #{seconds} seconds "
    (1..20).each do |i|
   motorpin.on
  sleep seconds.to_f
  motorpin.off
  sleep 2
  valvepin.on
  sleep valvesec.to_f
  valvepin.off
  sleep 5
 end

  else
    running = false
  end
end
flowsensor_on = false
sensorthreads.each { | thr | thr.join }
puts "Data generation complete"
