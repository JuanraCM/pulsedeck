# typed: true
# frozen_string_literal: true

module Pulsedeck
  module Components
    # typed: true because the Phlex HTML DSL is generated at runtime.
    # Shows the last `readings` values of one provider as a line. The browser draws the line (Chart.js).
    class LineGraphWidget < Widget
      extend T::Sig

      DEFAULT_READINGS = 60

      sig { returns(Integer) }
      attr_reader :readings

      sig { params(provider: Providers::Base, placement: Placement, readings: Integer).void }
      def initialize(provider:, placement:, readings: DEFAULT_READINGS)
        raise ArgumentError, 'readings must be 2 or more' if readings < 2

        @provider = provider
        @placement = placement
        @readings = readings
        super()
      end

      sig { void }
      def view_template
        render(Panel.new(title: @provider.label, placement: @placement)) do
          div(class: 'graph') do
            canvas(data: { graph: @provider.id, readings: @readings, unit: @provider.unit })
          end
        end
      end
    end
  end
end
