# typed: true
# frozen_string_literal: true

module Pulsedeck
  # typed: true because the Sinatra route DSL (`get`) is not fully typed.
  class App < Sinatra::Base
    extend T::Sig

    UPDATE_INTERVAL = 1.0

    # The default public folder is relative to the Sinatra root (lib/pulsedeck), so set it here.
    set :public_folder, File.expand_path('../../public', __dir__)

    error Config::Error do
      T.bind(self, Pulsedeck::App)
      status 500
      content_type 'text/html'
      Views::ConfigError.new(message: T.cast(env['sinatra.error'], Config::Error).message).call
    end

    get '/' do
      T.bind(self, Pulsedeck::App)
      content_type 'text/html'
      Config.load.call
    end

    get '/events' do
      T.bind(self, Pulsedeck::App)
      version = Config.version
      providers = Config.load.providers
      [200, { 'content-type' => 'text/event-stream', 'cache-control' => 'no-cache' },
       EventStream.new(providers: providers, interval: UPDATE_INTERVAL, stale: -> { Config.version != version })]
    end
  end
end
