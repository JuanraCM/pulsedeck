# typed: strict
# frozen_string_literal: true

module Pulsedeck
  # Builds the dashboard from the YAML config file.
  module Config
    extend T::Sig

    # Raised when the config file is not valid. The message starts with the file path.
    class Error < StandardError; end

    DEFAULT = <<~YAML
      # Size of the dashboard grid, in cells.
      grid:
        columns: 3
        rows: 4

      # Each widget has a provider and a placement.
      # column and row start at 1. width and height are optional (default 1).
      widgets:
        - provider: cpu_load # Provider id. Known ids: cpu_temperature, cpu_load, gpu_temperature, gpu_power, gpu_load, ram_usage, vram_usage
          column: 1
          row: 1
          height: 2
        - provider: cpu_temperature
          column: 1
          row: 3
          height: 2
        - provider: gpu_power
          column: 2
          row: 1
          height: 2
        - provider: gpu_load
          column: 2
          row: 3
        - provider: gpu_temperature
          column: 2
          row: 4
        - provider: ram_usage
          column: 3
          row: 1
          height: 2
        - provider: vram_usage
          column: 3
          row: 3
          height: 2
    YAML

    PROVIDERS = T.let({
      'cpu_temperature' => Providers::CpuTemperature,
      'cpu_load' => Providers::CpuLoad,
      'gpu_temperature' => Providers::GpuTemperature,
      'gpu_power' => Providers::GpuPower,
      'gpu_load' => Providers::GpuLoad,
      'ram_usage' => Providers::RamUsage,
      'vram_usage' => Providers::VramUsage
    }.freeze, T::Hash[String, T.class_of(Providers::Base)])

    sig { returns(String) }
    def self.path
      File.join(Dir.home, '.config', 'pulsedeck', 'config.yml')
    end

    # The modification time of the config file, or nil when the file does not exist.
    sig { params(path: String).returns(T.nilable(Time)) }
    def self.version(path = self.path)
      File.mtime(path)
    rescue SystemCallError
      nil
    end

    sig { params(path: String).returns(Views::Dashboard) }
    def self.load(path = self.path)
      write_default(path) unless File.exist?(path)
      build(T.let(YAML.safe_load_file(path), T.untyped))
    rescue Psych::SyntaxError, KeyError, TypeError, ArgumentError => e
      raise Error, "#{path}: #{e.message}"
    end

    sig { params(path: String).void }
    def self.write_default(path)
      FileUtils.mkdir_p(File.dirname(path))
      File.write(path, DEFAULT)
    end

    sig { params(data: T.untyped).returns(Views::Dashboard) }
    def self.build(data)
      raise TypeError, 'The file must contain a mapping' unless data.is_a?(Hash)

      grid = fetch_hash(data, 'grid')
      widgets = data.fetch('widgets')
      raise TypeError, '"widgets" must be a list' unless widgets.is_a?(Array)

      Views::Dashboard.new(columns: grid.fetch('columns'), rows: grid.fetch('rows'),
                           widgets: widgets.map { |widget| build_widget(widget) })
    end

    sig { params(data: T::Hash[T.untyped, T.untyped], key: String).returns(T::Hash[T.untyped, T.untyped]) }
    def self.fetch_hash(data, key)
      value = data.fetch(key)
      raise TypeError, "\"#{key}\" must be a mapping" unless value.is_a?(Hash)

      value
    end

    sig { params(widget: T.untyped).returns(Components::ValueWidget) }
    def self.build_widget(widget)
      raise TypeError, 'Each widget must be a mapping' unless widget.is_a?(Hash)

      attributes = widget.transform_keys { |key| key.to_s.to_sym }
      id = attributes.delete(:provider) { raise KeyError, 'A widget has no "provider"' }
      Components::ValueWidget.new(provider: provider_class(id).new, placement: Placement.new(**T.unsafe(attributes)))
    end

    sig { params(id: T.untyped).returns(T.class_of(Providers::Base)) }
    def self.provider_class(id)
      PROVIDERS.fetch(id) do
        raise ArgumentError, "Unknown provider #{id.inspect}. Known providers: #{PROVIDERS.keys.join(', ')}"
      end
    end

    private_class_method :write_default, :build, :fetch_hash, :build_widget, :provider_class
  end
end
