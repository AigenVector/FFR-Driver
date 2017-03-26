#!/usr/bin/env ruby

require 'sinatra/base'
require 'json'

class Driver < Sinatra::Base
  configure do 
    set :bind, '0.0.0.0'
  end

  get '/' do
    { name: 'ffr-driver', status: 'UP' }.to_json
  end

  get '/config' do
    erb :config
  end

  post '/config' do
    puts "Received elasticsearchLocation #{params[:elasticsearchLocation]}"
    Process.detach( fork{ exec "ruby ./subprocess.rb #{params[:elasticsearchLocation]} &" } )
    erb :monitoring
  end
end

Driver.run!
