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
        columns: 4
        rows: 3

      # Each widget has a provider and a placement.
      # column and row start at 1. width and height are optional (default 1).
      widgets:
        - provider: cpu_temperature # Provider id. Known ids: cpu_temperature
          column: 1
          row: 1
          width: 2
          height: 2
        - provider: cpu_temperature
          column: 3
          row: 1
          width: 2
        - provider: cpu_temperature
          column: 3
          row: 2
          height: 2
        - provider: cpu_temperature
          column: 4
          row: 2
        - provider: cpu_temperature
          column: 1
          row: 3
        - provider: cpu_temperature
          column: 2
          row: 3
        - provider: cpu_temperature
          column: 4
          row: 3
    YAML

    PROVIDERS = T.let({ 'cpu_temperature' => Providers::CpuTemperature }.freeze,
                      T::Hash[String, T.class_of(Providers::Base)])

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
