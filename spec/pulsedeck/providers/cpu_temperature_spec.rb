# typed: false
# frozen_string_literal: true

RSpec.describe Pulsedeck::Providers::CpuTemperature do
  it 'converts millidegrees to degrees' do
    add_hwmon_device(3, 'k10temp', 'temp1_input' => "47250\n")
    expect(described_class.new.read).to eq(47.25)
  end

  it 'returns nil without a k10temp device' do
    expect(described_class.new.read).to be_nil
  end

  it 'has a label and a unit', :aggregate_failures do
    provider = described_class.new
    expect(provider.label).to eq('CPU temperature')
    expect(provider.unit).to eq('°C')
  end
end
