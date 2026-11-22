# typed: true
# frozen_string_literal: true

module Pulsedeck
  module Components
    # typed: true because the Phlex HTML DSL is generated at runtime.
    class ValueWidget < Widget
      extend T::Sig

      sig { params(provider: Providers::Base, placement: Placement).void }
      def initialize(provider:, placement:)
        @provider = provider
        @placement = placement
        super()
      end

      sig { void }
      def view_template
        render(Panel.new(title: @provider.label, placement: @placement)) { value_span('value-fit') }
      end
    end
  end
end
