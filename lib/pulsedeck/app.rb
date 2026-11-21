# typed: true
# frozen_string_literal: true

module Pulsedeck
  # typed: true because the Sinatra route DSL (`get`) is not fully typed.
  class App < Sinatra::Base
    extend T::Sig

    UPDATE_INTERVAL = 1.0

    error Config::Error do
      T.bind(self, Pulsedeck::App)
      status 500
      content_type 'text/plain'
      T.cast(env['sinatra.error'], Config::Error).message
    end

    get '/' do
      T.bind(self, Pulsedeck::App)
      content_type 'text/html'
      Config.load.call
    end

    get '/events' do
      T.bind(self, Pulsedeck::App)
      [200, { 'content-type' => 'text/event-stream', 'cache-control' => 'no-cache' },
       EventStream.new(providers: Config.load.providers, interval: UPDATE_INTERVAL)]
    end
  end
end
