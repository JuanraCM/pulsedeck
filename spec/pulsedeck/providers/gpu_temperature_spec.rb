# typed: false
# frozen_string_literal: true

RSpec.describe Pulsedeck::Providers::GpuTemperature do
  it 'converts millidegrees to degrees' do
    add_hwmon_device(2, 'amdgpu', 'temp1_input' => "41000\n")
    expect(described_class.new.read).to eq(41.0)
  end

  it 'returns nil without an amdgpu device' do
    expect(described_class.new.read).to be_nil
  end

  it 'has an id, a label and a unit', :aggregate_failures do
    provider = described_class.new
    expect(provider.id).to eq('gpu_temperature')
    expect(provider.label).to eq('GPU temperature')
    expect(provider.unit).to eq('°C')
  end
end
