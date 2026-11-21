# typed: true
# frozen_string_literal: true

module Pulsedeck
  # typed: true because the Sinatra route DSL (`get`) is not fully typed.
  class App < Sinatra::Base
    extend T::Sig

    UPDATE_INTERVAL = 1.0
    # Duplicates the widget in Views::Dashboard until a widget config file is the one source for both.
    PROVIDERS = T.let([Providers::CpuTemperature.new].freeze, T::Array[Providers::Base])

    get '/' do
      T.bind(self, Pulsedeck::App)
      content_type 'text/html'
      Views::Dashboard.default.call
    end

    get '/events' do
      T.bind(self, Pulsedeck::App)
      [200, { 'content-type' => 'text/event-stream', 'cache-control' => 'no-cache' },
       EventStream.new(providers: PROVIDERS, interval: UPDATE_INTERVAL)]
    end
  end
end
