# typed: true
# frozen_string_literal: true

module Pulsedeck
  module Components
    # typed: true because the Phlex HTML DSL is generated at runtime.
    # Abstract base class for all widgets. A widget owns one provider and one placement.
    class Widget < Phlex::HTML
      extend T::Sig
      extend T::Helpers

      abstract!

      sig { returns(Placement) }
      attr_reader :placement

      sig { returns(Providers::Base) }
      attr_reader :provider
    end
  end
end
