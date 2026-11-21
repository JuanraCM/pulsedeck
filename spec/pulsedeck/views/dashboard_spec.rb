# typed: false
# frozen_string_literal: true

RSpec.describe Pulsedeck::Views::Dashboard do
  let(:widget) do
    lambda do |**placement|
      Pulsedeck::Components::ValueWidget.new(provider: Pulsedeck::Providers::CpuTemperature.new,
                                             placement: Pulsedeck::Placement.new(**placement))
    end
  end

  describe '#providers' do
    it 'returns the providers of the widgets, one for each id', :aggregate_failures do
      dashboard = described_class.new(columns: 2, rows: 2, widgets: [widget.call(column: 1, row: 1),
                                                                     widget.call(column: 2, row: 1)])
      expect(dashboard.providers.map(&:id)).to eq(['cpu_temperature'])
      expect(dashboard.providers.first).to be_a(Pulsedeck::Providers::CpuTemperature)
    end
  end

  it 'raises when a placement is outside the grid', :aggregate_failures do
    expect { described_class.new(columns: 2, rows: 2, widgets: [widget.call(column: 2, row: 1, width: 2)]) }
      .to raise_error(ArgumentError)
    expect { described_class.new(columns: 2, rows: 2, widgets: [widget.call(column: 1, row: 3)]) }
      .to raise_error(ArgumentError)
  end

  it 'accepts a placement at the grid edge' do
    expect { described_class.new(columns: 2, rows: 2, widgets: [widget.call(column: 2, row: 2)]) }.not_to raise_error
  end

  describe 'with a line graph widget' do
    let(:dashboard) do
      graph = Pulsedeck::Components::LineGraphWidget.new(provider: Pulsedeck::Providers::CpuLoad.new,
                                                         placement: Pulsedeck::Placement.new(column: 1, row: 1))
      described_class.new(columns: 1, rows: 1, widgets: [graph])
    end

    it 'loads Chart.js before the script and draws the graph', :aggregate_failures do
      html = dashboard.call
      expect(html).to include('<script src="/vendor/chart.umd.min.js"></script>', 'data-graph="cpu_load"')
      expect(html.index('chart.umd.min.js')).to be < html.index('new Chart(')
      expect(described_class::SCRIPT).to include('new Chart(', 'data-graph')
    end

    it 'includes the graph provider' do
      expect(dashboard.providers.map(&:id)).to eq(['cpu_load'])
    end
  end

  describe 'SCRIPT' do
    it 'reloads the page when the server state changes', :aggregate_failures do
      expect(described_class::SCRIPT).to include("EventSource('/events')", 'location.reload()')
      expect(described_class::SCRIPT).not_to include('fetch(')
    end
  end
end
