# typed: true
# frozen_string_literal: true

module Pulsedeck
  module Views
    # typed: true because the Phlex HTML DSL is generated at runtime.
    class Dashboard < Phlex::HTML
      extend T::Sig

      Widgets = T.type_alias { T::Array[T.any(Components::ValueWidget, Components::LineGraphWidget)] }

      sig { params(columns: Integer, rows: Integer, widgets: Widgets).void }
      def initialize(columns:, rows:, widgets:)
        widgets.each { |widget| check_bounds(widget.placement, columns, rows) }
        @columns = columns
        @rows = rows
        @widgets = widgets
        super()
      end

      sig { returns(T::Array[Providers::Base]) }
      def providers
        @widgets.map(&:provider).uniq(&:id)
      end

      sig { void }
      def view_template
        render Components::Layout.new do
          render Components::Grid.new(columns: @columns, rows: @rows) do
            @widgets.each { |widget| render widget }
          end
          script(src: '/vendor/chart.umd.min.js')
          script(src: '/js/graphs.js')
          script(src: '/js/events.js')
        end
      end

      private

      sig { params(placement: Placement, columns: Integer, rows: Integer).void }
      def check_bounds(placement, columns, rows)
        return if placement.column + placement.width - 1 <= columns && placement.row + placement.height - 1 <= rows

        raise ArgumentError, "Placement is outside the #{columns} x #{rows} grid"
      end
    end
  end
end
