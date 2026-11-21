# typed: false
# frozen_string_literal: true

require 'tmpdir'

RSpec.describe Pulsedeck::Providers::RamUsage do
  let(:dir) { Dir.mktmpdir }
  let(:meminfo) { File.join(dir, 'meminfo') }

  before { stub_const('Pulsedeck::Providers::RamUsage::MEMINFO', meminfo) }
  after { FileUtils.remove_entry(dir) }

  it 'subtracts available memory from total memory' do
    File.write(meminfo, "MemTotal:       32121476 kB\nMemFree:  100 kB\nMemAvailable:   27292304 kB\n")
    expect(described_class.new.read).to be_within(0.05).of(4.6)
  end

  it 'returns nil for a missing file' do
    expect(described_class.new.read).to be_nil
  end

  it 'returns nil when a field is missing' do
    File.write(meminfo, "MemTotal:       32121476 kB\n")
    expect(described_class.new.read).to be_nil
  end

  it 'has an id, a label and a unit', :aggregate_failures do
    provider = described_class.new
    expect(provider.id).to eq('ram_usage')
    expect(provider.label).to eq('RAM usage')
    expect(provider.unit).to eq('GB')
  end
end
