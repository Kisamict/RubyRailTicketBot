require 'sinatra/base'
require 'sinatra/activerecord'
require 'json'

Dir['./models/*.rb'].sort.each { |f| require f }

require_relative 'api'

Api.run!
