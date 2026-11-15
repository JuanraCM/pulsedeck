# typed: false
# frozen_string_literal: true

RSpec.describe Pulsedeck::Views::Dashboard do
  it 'renders the CPU temperature widget', :aggregate_failures do
    add_hwmon_device(3, 'k10temp', 'temp1_input' => '47250')
    html = described_class.new.call
    expect(html).to include('CPU temperature', '47.2 °C')
    expect(html.scan('class="panel"').size).to eq(1)
  end

  it 'shows N/A when the sensor is missing' do
    expect(described_class.new.call).to include('N/A')
  end
end
