# typed: false
# frozen_string_literal: true

RSpec.describe Pulsedeck::Providers::VramUsage do
  it 'converts the raw value' do
    add_hwmon_device(2, 'amdgpu')
    FileUtils.mkdir_p(File.join(hwmon_root, 'hwmon2', 'device'))
    File.write(File.join(hwmon_root, 'hwmon2', 'device', 'mem_info_vram_used'), "536870912\n")
    expect(described_class.new.read).to eq(0.5)
  end

  it 'returns nil without an amdgpu device' do
    expect(described_class.new.read).to be_nil
  end

  it 'has an id, a label and a unit', :aggregate_failures do
    provider = described_class.new
    expect(provider.id).to eq('vram_usage')
    expect(provider.label).to eq('VRAM usage')
    expect(provider.unit).to eq('GB')
  end
end
