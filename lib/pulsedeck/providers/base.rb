# typed: strict
# frozen_string_literal: true

module Pulsedeck
  module Providers
    # Abstract base class for all hardware metric providers.
    class Base
      extend T::Sig
      extend T::Helpers

      abstract!

      sig { abstract.returns(String) }
      def id; end

      sig { abstract.returns(String) }
      def label; end

      sig { abstract.returns(String) }
      def unit; end

      sig { abstract.returns(T.nilable(Float)) }
      def read; end

      # Value rounded one time, so the server and the browser show the same text.
      sig { returns(T.nilable(Float)) }
      def value
        T.cast(read&.round(1), T.nilable(Float))
      end
    end
  end
end
