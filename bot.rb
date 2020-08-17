# frozen_string_literal: true

class TelegramBot
  include Queryable

  TOKEN = ENV['TICKET_BOT_TOKEN']

  def run
    Telegram::Bot::Client.run(TOKEN) do |bot|
      @bot = bot
      @markup ||= message_markup

      @bot.listen do |message|
        @chat_id = message.from.id

        case message
        when Telegram::Bot::Types::CallbackQuery
          process_callback(message)
        when Telegram::Bot::Types::Message
          process_input(message)
        end
      end
    end
  end

  private

  def process_input(message)
    case message.text
    when '/start'
      response_message = "Hello, #{message.from.first_name}! "\
                         'Welcome to my rail-ticket-bot! You are able to:'

      send_message(response_message, @markup)
    when /,\s*/
      message_body = message.text.split(',').map(&:strip)

      if message_body.size == 7
        buy_ticket(message_body)
      elsif message_body.size == 4
        show_tickets(message_body)
      else
        send_message('Invalid input', @markup)
      end
    else
      send_message("I'm sorry, my responses are limited. But you are able to:", @markup)
    end
  end

  def process_callback(message)
    case message.data
    when 'schedule'
      routes = get_request('http://localhost:4567/routes')

      response_message = routes.map.with_index do |route, index|
        "Route##{index + 1}\n"\
        "Route name: #{route['name']}\n"\
        "Departure time: #{route['departure_time']}\n"\
        "Arrival time: #{route['arrival_time']}\n"\
      end.join("\n")

      send_message(response_message, @markup)
    when 'buy_ticket'
      response_message = "Please, enter the data in following format:\n"\
                         "First name, last name, date of birth(DD.MM.YYYY), passport ID\n"\
                         'route name, date of departure(DD.MM.YYYY HH:MM), date of arrival(DD.MM.YYYY HH:MM)'

      send_message(response_message)
    when 'tickets'
      response_message = "Please, enter passenger's data in following format:\n"\
                         'First name, last name, date of birth(DD.MM.YYYY), passport ID'

      send_message(response_message)
    when 'stop'
      send_message('Bye-bye!')
    end
  end

  def message_markup
    buttons_data = {
      'schedule': 'Check trains schedule',
      'buy_ticket': 'Buy ticket',
      'tickets': 'Check your tickets',
      'stop': 'Stop'
    }

    buttons = buttons_data.map do |data, text|
      Telegram::Bot::Types::InlineKeyboardButton.new(text: text, callback_data: data)
    end

    Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: buttons)
  end

  def buy_ticket(message_body)
    req_body = {
      "first_name": message_body[0],
      "last_name": message_body[1],
      "birth_date": message_body[2],
      "passport_id": message_body[3],
      "route_name": message_body[4],
      "departure_time": message_body[5],
      "arrival_time": message_body[6]
    }

    res = post_request('http://localhost:4567/buy_ticket', req_body)

    return send_message('Route not found. Please, check your input', @markup) if res.code == '404'

    send_message('Ticket purchased successfully', @markup)
  end

  def show_tickets(message_body)
    req_body = {
      "first_name": message_body[0],
      "last_name": message_body[1],
      "birth_date": message_body[2],
      "passport_id": message_body[3]
    }

    tickets = get_request('http://localhost:4567/passenger_tickets', req_body)

    return send_message('No tickets found for such passenger', @markup) unless tickets

    response_message = tickets.map.with_index do |ticket, index|
      "Ticket##{index + 1}\n"\
      "First name: #{ticket['first_name']}\n"\
      "Last name: #{ticket['last_name']}\n"\
      "Route name: #{ticket['route_name']}\n"\
      "Departure time: #{ticket['departure_time']}\n"\
      "Arrival time: #{ticket['arrival_time']}\n"\
    end.join("\n")

    send_message("Passenger's tickets:\n#{response_message}", @markup)
  end

  def send_message(message_body, reply_markup = nil)
    if reply_markup
      @bot.api.send_message(chat_id: @chat_id, text: message_body, reply_markup: reply_markup)
    elsif reply_markup.nil?
      @bot.api.send_message(chat_id: @chat_id, text: message_body)
    end
  end
end
