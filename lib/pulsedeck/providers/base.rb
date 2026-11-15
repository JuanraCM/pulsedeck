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
      def label; end

      sig { abstract.returns(String) }
      def unit; end

      sig { abstract.returns(T.nilable(Float)) }
      def read; end
    end
  end
end
