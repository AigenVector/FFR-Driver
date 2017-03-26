#!/usr/bin/env ruby

require 'sinatra/base'
require 'pi_piper'

class Driver < Sinatra::Base

  configure do 
    set :bind, '0.0.0.0'
    set :pin, PiPiper::Pin.new(:pin => 2, :direction => :out)
  end

  get '/' do
    'Check this out'
  end

  get '/on' do
    settings.pin.on
  end

  get '/off' do
    settings.pin.off
  end
end

Driver.run!
