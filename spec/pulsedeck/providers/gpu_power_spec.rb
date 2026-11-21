# typed: false
# frozen_string_literal: true

RSpec.describe Pulsedeck::Providers::GpuPower do
  it 'converts the raw value' do
    add_hwmon_device(2, 'amdgpu', 'power1_average' => "45500000\n")
    expect(described_class.new.read).to eq(45.5)
  end

  it 'uses power1_input when power1_average is missing' do
    add_hwmon_device(2, 'amdgpu', 'power1_input' => "30000000\n")
    expect(described_class.new.read).to eq(30.0)
  end

  it 'returns nil without an amdgpu device' do
    expect(described_class.new.read).to be_nil
  end

  it 'has an id, a label and a unit', :aggregate_failures do
    provider = described_class.new
    expect(provider.id).to eq('gpu_power')
    expect(provider.label).to eq('GPU power')
    expect(provider.unit).to eq('W')
  end
end
