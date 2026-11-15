# typed: strict
# frozen_string_literal: true

module Pulsedeck
  # Rack body for a Server-Sent Events stream. Each interval it sends one message with the value of every provider.
  # It is not an Array, so Puma writes each message to the socket at once.
  class EventStream
    extend T::Sig

    sig { params(providers: T::Array[Providers::Base], interval: Numeric).void }
    def initialize(providers:, interval:)
      @providers = providers
      @interval = interval
    end

    sig { params(block: T.proc.params(frame: String).void).void }
    def each(&block)
      loop do
        block.call(frame)
        sleep(@interval)
      end
    end

    private

    sig { returns(String) }
    def frame
      "data: #{JSON.generate(@providers.to_h { |provider| [provider.id, provider.value] })}\n\n"
    end
  end
end
