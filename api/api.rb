# frozen_string_literal: true

class Api < Sinatra::Application
  set :database, {
    adapter: 'postgresql',
    encoding: 'unicode',
    database: 'testdb',
    pool: 2,
    username: 'andrew',
    password: '1111'
  }

  helpers do
    def create_pasenger(data)
      Passenger.create(
        first_name: data['first_name'],
        last_name: data['last_name'],
        birth_date: data['birth_date'],
        passport_id: data['passport_id'],
        tickets: []
      )
    end

    def create_ticket(data)
      Ticket.create(
        first_name: data['first_name'],
        last_name: data['last_name'],
        route_name: data['route_name'],
        departure_time: data['departure_time'],
        arrival_time: data['arrival_time']
      )
    end

    def find_passenger(data)
      Passenger.find_by(
        first_name: data['first_name'],
        last_name: data['last_name'],
        passport_id: data['passport_id']
      )
    end

    def find_route(data)
      Route.find_by(
        name: data['route_name'],
        departure_time: data['departure_time'],
        arrival_time: data['arrival_time']
      )
    end
  end

  get '/passenger_tickets' do
    content_type :json
    req = JSON.parse(request.body.read)

    passenger = Passenger.find_by(
      first_name: req['first_name'],
      last_name: req['last_name'],
      passport_id: req['passport_id']
    )

    passenger&.tickets.to_json
  end

  get '/routes' do
    content_type :json
    Route.all.to_json
  end

  post '/create_route' do
    route_data = request.body.read
    Route.create(JSON.parse(route_data))
  end

  post '/buy_ticket' do
    req = JSON.parse(request.body.read)

    passenger = find_passenger(req)
    route = find_route(req)

    halt 404, 'Route not found' unless route

    if passenger
      passenger.tickets << create_ticket(req)
      passenger.save
    else
      passenger = create_pasenger(req)

      passenger.tickets << create_ticket(req)
      passenger.save
    end
  end
end
