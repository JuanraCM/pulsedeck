# typed: true
# frozen_string_literal: true

module Pulsedeck
  # typed: true because the Sinatra route DSL (`get`) is not fully typed.
  class App < Sinatra::Base
    extend T::Sig

    get '/' do
      T.bind(self, Pulsedeck::App)
      content_type 'text/html'
      Views::TestPage.new.call
    end
  end
end
