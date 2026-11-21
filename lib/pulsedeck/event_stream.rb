# typed: strict
# frozen_string_literal: true

module Pulsedeck
  # Rack body for a Server-Sent Events stream. Each interval it sends one message with the value of every provider.
  # It ends when the stale callable returns true.
  # It is not an Array, so Puma writes each message to the socket at once.
  class EventStream
    extend T::Sig

    sig do
      params(providers: T::Array[Providers::Base], interval: Numeric, stale: T.proc.returns(T::Boolean)).void
    end
    def initialize(providers:, interval:, stale:)
      @providers = providers
      @interval = interval
      @stale = stale
    end

    sig { params(block: T.proc.params(frame: String).void).void }
    def each(&block)
      loop do
        break if @stale.call

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
