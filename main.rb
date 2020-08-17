require 'telegram/bot'
require 'net/http'
require 'json'
require './modules/queryable'

require_relative 'bot'

TelegramBot.new.run
