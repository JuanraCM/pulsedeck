# typed: true
# frozen_string_literal: true

module Pulsedeck
  module Views
    # typed: true because the Phlex HTML DSL is generated at runtime.
    class Dashboard < Phlex::HTML
      extend T::Sig

      SCRIPT = <<~JS
        const graphs = [];
        for (const canvas of document.querySelectorAll('canvas[data-graph]')) {
          const readings = Number(canvas.dataset.readings);
          const unit = canvas.dataset.unit;
          const chart = new Chart(canvas, {
            type: 'line',
            data: {
              labels: new Array(readings).fill(''),
              datasets: [{
                data: new Array(readings).fill(null),
                borderColor: '#4fc3f7', borderWidth: 2, pointRadius: 0, tension: 0
              }]
            },
            options: {
              animation: false,
              responsive: true,
              maintainAspectRatio: false,
              plugins: { legend: { display: false }, tooltip: { enabled: false } },
              scales: {
                x: { display: false },
                y: { ticks: { color: '#999', callback: (v) => `${v} ${unit}` }, grid: { color: '#333' } }
              }
            }
          });
          graphs.push({ id: canvas.dataset.graph, chart });
        }
        let stale = false;
        const source = new EventSource('/events');
        source.onopen = () => {
          if (stale) location.reload();
        };
        source.onerror = () => {
          stale = true;
          // CLOSED: the server answered with an error (invalid config). Show the error page.
          if (source.readyState === EventSource.CLOSED) location.reload();
        };
        source.onmessage = (event) => {
          const values = JSON.parse(event.data);
          for (const [id, value] of Object.entries(values)) {
            for (const el of document.querySelectorAll(`[data-metric="${id}"]`)) {
              el.textContent = value === null ? 'N/A' : `${value.toFixed(1)} ${el.dataset.unit}`;
            }
          }
          for (const { id, chart } of graphs) {
            if (!(id in values)) continue;
            const data = chart.data.datasets[0].data;
            data.push(values[id]);
            data.shift();
            chart.update('none');
          }
        };
      JS

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
