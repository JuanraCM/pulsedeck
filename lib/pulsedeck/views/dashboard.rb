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

      sig { void }
      def view_template
        render Components::Layout.new do
          h1 { 'Pulsedeck' }
          render Components::Grid.new(columns: 1, rows: 1) do
            render Components::ValueWidget.new(provider: Providers::CpuTemperature.new,
                                               placement: Placement.new(column: 1, row: 1))
          end
          script { raw safe(SCRIPT) }
        end
      end
    end
  end
end
