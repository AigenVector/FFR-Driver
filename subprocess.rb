#!/usr/bin/env ruby

require 'elasticsearch'
require 'pi_piper'

# Show that we can use the GPIO from teh subprocess
pin = PiPiper::Pin.new(:pin => 2, :direction => :out)

# Connect to ES and generate some random data to test visualizaiton
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
            sensor_0: {
              type: 'double',
              index: 'not_analyzed',
              fields: {
                raw: {
                  type: 'keyword'
                }
              }
            },
            sensor_1: {
              type: 'double',
              index: 'not_analyzed',
              fields: {
                raw: {
                  type: 'keyword'
                }
              }
            },
            sensor_2: {
              type: 'double',
              index: 'not_analyzed',
              fields: {
                raw: {
                  type: 'keyword'
                }
              }
            }
          }
        }
      }
    }, wait_for_active_shards: 1
    puts "Index created."
end
puts "Generating data now."
rand = Random.new
(0...100).each do |x|
  # Blinky lights!!!
  if x % 2 == 0
    pin.off
  else
    pin.on
  end
  sleep 0.5
  es.index index: 'test-project-index',
    type: 'sensor_data',
    body: {
      timestamp: (Time.now.to_f * 1000.0).to_i,
      sensor_0: rand.rand(70.0),
      sensor_1: rand.rand(70.0),
      sensor_2: rand.rand(70.0)
    }
end
puts "Data generation complete"
