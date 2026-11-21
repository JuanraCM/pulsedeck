# typed: false
# frozen_string_literal: true

RSpec.describe Pulsedeck::Providers::GpuLoad do
  it 'converts the raw value' do
    add_hwmon_device(2, 'amdgpu')
    FileUtils.mkdir_p(File.join(hwmon_root, 'hwmon2', 'device'))
    File.write(File.join(hwmon_root, 'hwmon2', 'device', 'gpu_busy_percent'), "7\n")
    expect(described_class.new.read).to eq(7.0)
  end

  it 'returns nil without an amdgpu device' do
    expect(described_class.new.read).to be_nil
  end

  it 'has an id, a label and a unit', :aggregate_failures do
    provider = described_class.new
    expect(provider.id).to eq('gpu_load')
    expect(provider.label).to eq('GPU load')
    expect(provider.unit).to eq('%')
  end
end
