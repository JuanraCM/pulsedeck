# typed: true
# frozen_string_literal: true

module Pulsedeck
  module Views
    # typed: true because the Phlex HTML DSL is generated at runtime.
    class Dashboard < Phlex::HTML
      extend T::Sig

      SCRIPT = <<~JS
        new EventSource('/events').onmessage = (event) => {
          for (const [id, value] of Object.entries(JSON.parse(event.data))) {
            for (const el of document.querySelectorAll(`[data-metric="${id}"]`)) {
              el.textContent = value === null ? 'N/A' : `${value.toFixed(1)} ${el.dataset.unit}`;
            }
          }
        };
      JS

      Widgets = T.type_alias { T::Array[Components::ValueWidget] }

      sig { returns(Dashboard) }
      def self.default
        new(columns: 4, rows: 3, widgets: [
              cpu_widget(1, 1, 2, 2), cpu_widget(3, 1, 2, 1), cpu_widget(3, 2, 1, 2), cpu_widget(4, 2),
              cpu_widget(1, 3), cpu_widget(2, 3), cpu_widget(4, 3)
            ])
      end

      sig { params(column: Integer, row: Integer, width: Integer, height: Integer).returns(Components::ValueWidget) }
      def self.cpu_widget(column, row, width = 1, height = 1)
        placement = Placement.new(column: column, row: row, width: width, height: height)
        Components::ValueWidget.new(provider: Providers::CpuTemperature.new, placement: placement)
      end
      private_class_method :cpu_widget

      sig { params(columns: Integer, rows: Integer, widgets: Widgets).void }
      def initialize(columns:, rows:, widgets:)
        widgets.each { |widget| check_bounds(widget.placement, columns, rows) }
        @columns = columns
        @rows = rows
        @widgets = widgets
        super()
      end

      sig { void }
      def view_template
        render Components::Layout.new do
          h1 { 'Pulsedeck' }
          render Components::Grid.new(columns: @columns, rows: @rows) do
            @widgets.each { |widget| render widget }
          end
          script { raw safe(SCRIPT) }
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
