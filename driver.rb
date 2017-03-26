#!/usr/bin/env ruby

require 'sinatra/base'
require 'pi_piper'
require 'json'

class Driver < Sinatra::Base

  configure do 
    set :bind, '0.0.0.0'
    set :pin, PiPiper::Pin.new(:pin => 2, :direction => :out)
  end

  get '/' do
    { name: 'ffr-driver', status: 'UP' }.to_json
  end

  get '/config' do
    erb :config
  end

  post '/config' do
    puts "Received elasticsearchLocation #{params[:elasticsearchLocation]}"
    # Connect to ES in future and kick off a run here
    erb :monitoring
  end

  get '/on' do
    settings.pin.on
  end

  get '/off' do
    settings.pin.off
  end
end

Driver.run!
