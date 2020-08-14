require 'sinatra/base'
require 'sinatra/activerecord'
require 'json'
require_relative 'api'

Dir['./models/*.rb'].sort.each { |f| require f }

Api.run!
