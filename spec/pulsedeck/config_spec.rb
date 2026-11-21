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

  context 'when the file is missing' do
    it 'writes the default file', :aggregate_failures do
      described_class.load(path)
      expect(File.read(path)).to eq(described_class::DEFAULT)
    end

    it 'loads 7 panels in a 4 x 3 grid', :aggregate_failures do
      html = described_class.load(path).call
      expect(html.scan('class="panel"').size).to eq(7)
      expect(html).to include('repeat(4, 1fr)', 'repeat(3, 1fr)')
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
                                     "column: 2\n    row: 1\n    width: 2\n"
    }.each do |name, yaml|
      it "raises Config::Error with the path for #{name}" do
        write.call(yaml)
        expect { described_class.load(path) }.to raise_error(described_class::Error, /\A#{Regexp.escape(path)}: /)
      end
    end

    it 'lists the known provider ids' do
      write.call("grid:\n  columns: 2\n  rows: 2\nwidgets:\n  - provider: nope\n    column: 1\n    row: 1\n")
      expect { described_class.load(path) }.to raise_error(described_class::Error, /cpu_temperature/)
    end
  end
end
