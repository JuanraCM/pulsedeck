# typed: false
# frozen_string_literal: true

require 'tmpdir'

RSpec.describe Pulsedeck::Config do
  let(:dir) { Dir.mktmpdir }
  let(:path) { File.join(dir, 'pulsedeck', 'config.yml') }
  let(:write) do
    lambda do |yaml|
      FileUtils.mkdir_p(File.dirname(path))
      File.write(path, yaml)
    end
  end

  after { FileUtils.remove_entry(dir) }

  it 'reads the path from HOME on each call' do
    expect(described_class.path).to eq(File.join(Dir.home, '.config', 'pulsedeck', 'config.yml'))
  end

  describe '.version' do
    before do
      write.call('a')
      File.utime(Time.at(1_000), Time.at(1_000), path)
    end

    it 'returns the mtime' do
      expect(described_class.version(path)).to eq(Time.at(1_000))
    end

    it 'changes after a rewrite with a later mtime' do
      write.call('b')
      File.utime(Time.at(2_000), Time.at(2_000), path)
      expect(described_class.version(path)).to eq(Time.at(2_000))
    end

    it 'returns nil for a missing file' do
      FileUtils.rm_f(path)
      expect(described_class.version(path)).to be_nil
    end
  end

  context 'when the file is missing' do
    it 'writes the default file', :aggregate_failures do
      described_class.load(path)
      expect(File.read(path)).to eq(described_class::DEFAULT)
    end

    it 'loads 7 panels in a 3 x 4 grid', :aggregate_failures do
      html = described_class.load(path).call
      expect(html.scan('class="panel"').size).to eq(7)
      expect(html).to include('repeat(3, 1fr)', 'repeat(4, 1fr)')
    end

    it 'shows 7 different provider ids' do
      html = described_class.load(path).call
      ids = %w[cpu_temperature cpu_load ram_usage gpu_temperature gpu_power gpu_load vram_usage]
      expect(ids.map { |id| html.scan("data-metric=\"#{id}\"").size }).to eq([1] * 7)
    end

    it 'shows N/A when the sensor is missing' do
      expect(described_class.load(path).call).to include('N/A')
    end

    it 'shows the CPU temperature', :aggregate_failures do
      add_hwmon_device(3, 'k10temp', 'temp1_input' => '47250')
      expect(described_class.load(path).call).to include('CPU temperature', '47.3 °C')
    end

    it 'adds the event stream script', :aggregate_failures do
      html = described_class.load(path).call
      expect(html).to include('<script>', "EventSource('/events')")
    end
  end

  context 'with a valid custom file' do
    before do
      write.call(<<~YAML)
        grid:
          columns: 2
          rows: 2
        widgets:
          - provider: cpu_temperature
            column: 2
            row: 1
            height: 2
      YAML
    end

    it 'builds the grid and the widget', :aggregate_failures do
      html = described_class.load(path).call
      expect(html.scan('class="panel"').size).to eq(1)
      expect(html).to include('repeat(2, 1fr)')
    end

    it 'defaults width to 1', :aggregate_failures do
      placement = described_class.load(path).instance_variable_get(:@widgets).first.placement
      expect([placement.width, placement.height]).to eq([1, 2])
    end
  end

  context 'with line_graph widgets' do
    let(:widgets) { described_class.load(path).instance_variable_get(:@widgets) }

    before do
      write.call(<<~YAML)
        grid:
          columns: 3
          rows: 2
        widgets:
          - provider: cpu_load
            type: line_graph
            readings: 30
            column: 1
            row: 1
          - provider: ram_usage
            type: line_graph
            column: 2
            row: 1
          - provider: cpu_temperature
            column: 3
            row: 1
      YAML
    end

    it 'builds line graph widgets with the readings or the default', :aggregate_failures do
      expect(widgets.map(&:class)).to eq(([Pulsedeck::Components::LineGraphWidget] * 2) +
                                         [Pulsedeck::Components::ValueWidget])
      expect(widgets.first(2).map(&:readings)).to eq([30, 60])
    end
  end

  describe 'PROVIDERS' do
    described_class::PROVIDERS.each do |key, klass|
      it "builds a provider with the id #{key}" do
        expect(klass.new.id).to eq(key)
      end
    end
  end

  describe 'invalid file' do
    {
      'a YAML syntax error' => "grid: [\n",
      'a missing grid' => "widgets: []\n",
      'a missing widgets key' => "grid:\n  columns: 2\n  rows: 2\n",
      'an unknown provider' => "grid:\n  columns: 2\n  rows: 2\nwidgets:\n  - provider: nope\n    column: 1\n    " \
                               "row: 1\n",
      'an unknown widget key' => "grid:\n  columns: 2\n  rows: 2\nwidgets:\n  - provider: cpu_temperature\n    " \
                                 "column: 1\n    row: 1\n    color: red\n",
      'a non-integer value' => "grid:\n  columns: 2\n  rows: 2\nwidgets:\n  - provider: cpu_temperature\n    " \
                               "column: one\n    row: 1\n",
      'a value of 0' => "grid:\n  columns: 2\n  rows: 2\nwidgets:\n  - provider: cpu_temperature\n    " \
                        "column: 0\n    row: 1\n",
      'a widget outside the grid' => "grid:\n  columns: 2\n  rows: 2\nwidgets:\n  - provider: cpu_temperature\n    " \
                                     "column: 2\n    row: 1\n    width: 2\n",
      'an unknown widget type' => "grid:\n  columns: 2\n  rows: 2\nwidgets:\n  - provider: cpu_load\n    " \
                                  "type: pie\n    column: 1\n    row: 1\n",
      'readings of 1' => "grid:\n  columns: 2\n  rows: 2\nwidgets:\n  - provider: cpu_load\n    " \
                         "type: line_graph\n    readings: 1\n    column: 1\n    row: 1\n",
      'readings that is not an integer' => "grid:\n  columns: 2\n  rows: 2\nwidgets:\n  - provider: cpu_load\n    " \
                                           "type: line_graph\n    readings: many\n    column: 1\n    row: 1\n",
      'readings on a value widget' => "grid:\n  columns: 2\n  rows: 2\nwidgets:\n  - provider: cpu_load\n    " \
                                      "readings: 5\n    column: 1\n    row: 1\n"
    }.each do |name, yaml|
      it "raises Config::Error with the path for #{name}" do
        write.call(yaml)
        expect { described_class.load(path) }.to raise_error(described_class::Error, /\A#{Regexp.escape(path)}: /)
      end
    end

    it 'lists the known widget types' do
      write.call("grid: { columns: 2, rows: 2 }\nwidgets:\n  - { provider: cpu_load, type: pie, column: 1, row: 1 }\n")
      expect { described_class.load(path) }.to raise_error(described_class::Error, /value, line_graph/)
    end

    it 'lists the known provider ids' do
      write.call("grid:\n  columns: 2\n  rows: 2\nwidgets:\n  - provider: nope\n    column: 1\n    row: 1\n")
      expect { described_class.load(path) }.to raise_error(described_class::Error, /cpu_temperature/)
    end
  end
end
