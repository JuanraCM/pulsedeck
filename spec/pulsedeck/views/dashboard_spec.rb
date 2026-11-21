# typed: false
# frozen_string_literal: true

RSpec.describe Pulsedeck::Views::Dashboard do
  let(:widget) do
    lambda do |**placement|
      Pulsedeck::Components::ValueWidget.new(provider: Pulsedeck::Providers::CpuTemperature.new,
                                             placement: Pulsedeck::Placement.new(**placement))
    end
  end

  describe '.default' do
    let(:html) { described_class.default.call }

    it 'renders the CPU temperature in 7 panels', :aggregate_failures do
      add_hwmon_device(3, 'k10temp', 'temp1_input' => '47250')
      expect(html).to include('CPU temperature', '47.3 °C')
      expect(html.scan('class="panel"').size).to eq(7)
    end

    it 'fills a 4 x 3 grid' do
      expect(html).to include('repeat(4, 1fr)', 'repeat(3, 1fr)')
    end

    it 'shows N/A when the sensor is missing' do
      expect(html).to include('N/A')
    end

    it 'opens one event stream to update the widgets', :aggregate_failures do
      expect(html).to include('<script>')
      expect(html).to include("EventSource('/events')")
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
end
