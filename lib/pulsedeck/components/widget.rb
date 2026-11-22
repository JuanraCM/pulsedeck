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

      protected

      # Renders the live value. The browser updates it through data-metric and data-unit.
      sig { params(extra_class: T.nilable(String)).void }
      def value_span(extra_class = nil)
        value = @provider.value
        span(class: ['value', extra_class].compact, data: { metric: @provider.id, unit: @provider.unit }) do
          value.nil? ? 'N/A' : "#{value} #{@provider.unit}"
        end
      end
    end
  end
end
