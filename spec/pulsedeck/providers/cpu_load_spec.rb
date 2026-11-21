# typed: false
# frozen_string_literal: true

require 'tmpdir'

RSpec.describe Pulsedeck::Providers::CpuLoad do
  let(:dir) { Dir.mktmpdir }
  let(:stat) { File.join(dir, 'stat') }

  before { stub_const('Pulsedeck::Providers::CpuLoad::STAT', stat) }
  after { FileUtils.remove_entry(dir) }

  it 'reads the average since boot first' do
    # idle 700 + iowait 100 = 800 of total 1000
    File.write(stat, "cpu  100 0 100 700 100 0 0 0 0 0\ncpu0 1 1 1 1 1 0 0 0 0 0\n")
    expect(described_class.new.read).to be_within(0.001).of(20.0)
  end

  it 'reads the load of the delta on the second read' do
    File.write(stat, "cpu  100 0 100 700 100 0 0 0 0 0\n")
    provider = described_class.new
    provider.read
    # delta: idle +50, total +100
    File.write(stat, "cpu  130 0 120 740 110 0 0 0 0 0\n")
    expect(provider.read).to be_within(0.001).of(50.0)
  end

  it 'returns nil for a missing file' do
    expect(described_class.new.read).to be_nil
  end

  it 'returns nil for a file that does not parse' do
    File.write(stat, "garbage\n")
    expect(described_class.new.read).to be_nil
  end

  it 'returns nil when the total delta is 0' do
    File.write(stat, "cpu  100 0 100 700 100 0 0 0 0 0\n")
    provider = described_class.new
    provider.read
    expect(provider.read).to be_nil
  end

  it 'has an id, a label and a unit', :aggregate_failures do
    provider = described_class.new
    expect(provider.id).to eq('cpu_load')
    expect(provider.label).to eq('CPU load')
    expect(provider.unit).to eq('%')
  end
end
