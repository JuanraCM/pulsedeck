# typed: false
# frozen_string_literal: true

RSpec.describe Pulsedeck::App do
  let(:app) { described_class }

  describe 'GET /' do
    before { get '/' }

    it 'returns an HTML page', :aggregate_failures do
      expect(last_response.status).to eq(200)
      expect(last_response.content_type).to include('text/html')
    end

    it 'has the title and the CPU temperature panel', :aggregate_failures do
      body = last_response.body
      expect(body).to include('<title>Pulsedeck</title>')
      expect(body).to include('CPU temperature')
    end

    it 'renders the 6 panels of the default dashboard and the event stream script', :aggregate_failures do
      expect(last_response.body).not_to include('http-equiv="refresh"')
      expect(last_response.body.scan('class="panel"').size).to eq(7)
      expect(last_response.body).to include("EventSource('/events')")
    end

    it 'shows a data-metric for each default provider' do
      ids = %w[cpu_temperature cpu_load ram_usage gpu_temperature gpu_power gpu_load vram_usage]
      expect(ids.map { |id| last_response.body.include?("data-metric=\"#{id}\"") }).to all(be(true))
    end

    it 'writes the default config file' do
      expect(File.read(Pulsedeck::Config.path)).to eq(Pulsedeck::Config::DEFAULT)
    end
  end

  describe 'GET / with an invalid config file' do
    before do
      FileUtils.mkdir_p(File.dirname(Pulsedeck::Config.path))
      File.write(Pulsedeck::Config.path, "grid: [\n")
      get '/'
    end

    it 'returns 500 with the path and the message, and renders no dashboard', :aggregate_failures do
      expect(last_response.status).to eq(500)
      expect(last_response.content_type).to include('text/html')
      expect(last_response.body).to include(Pulsedeck::Config.path)
      expect(last_response.body).not_to include('class="panel"')
    end

    it 'reloads itself so the dashboard returns when the file is valid' do
      expect(last_response.body).to include('http-equiv="refresh"')
    end

    it 'escapes the message', :aggregate_failures do
      File.write(Pulsedeck::Config.path, "grid: { columns: 1, rows: 1 }\nwidgets: [{ provider: '<b>' }]\n")
      get '/'
      expect(last_response.body).to include('&lt;b&gt;')
      expect(last_response.body).not_to include('<b>')
    end
  end

  describe 'GET /events' do
    before do
      Pulsedeck::Config.load # Writes the default file, so the version does not change.
      allow(Pulsedeck::EventStream).to receive(:new).and_wrap_original do |original, **args|
        original.call(**args).tap { |stream| allow(stream).to receive(:sleep).and_raise(StopIteration) }
      end
      get '/events'
    end

    it 'streams the metric values as server-sent events', :aggregate_failures do
      expect(last_response.status).to eq(200)
      expect(last_response.content_type).to include('text/event-stream')
      expect(last_response.body).to start_with('data: {').and include('"cpu_temperature":')
    end
  end

  describe 'GET /events when the config version changes' do
    before do
      allow(Pulsedeck::Config).to receive(:version).and_return(1, 2)
      get '/events'
    end

    it 'ends the stream with an empty body', :aggregate_failures do
      expect(last_response.status).to eq(200)
      expect(last_response.body).to be_empty
    end
  end

  describe 'GET /events with a custom config file' do
    before do
      FileUtils.mkdir_p(File.dirname(Pulsedeck::Config.path))
      File.write(Pulsedeck::Config.path, "grid:\n  columns: 1\n  rows: 1\nwidgets: []\n")
      allow(Pulsedeck::EventStream).to receive(:new).and_wrap_original do |original, **args|
        original.call(**args).tap { |stream| allow(stream).to receive(:sleep).and_raise(StopIteration) }
      end
      get '/events'
    end

    it 'streams the providers from the file' do
      expect(last_response.body).to start_with('data: {}')
    end
  end

  describe 'GET /vendor/chart.umd.min.js' do
    before { get '/vendor/chart.umd.min.js' }

    it 'serves the vendored Chart.js file', :aggregate_failures do
      expect(last_response.status).to eq(200)
      expect(last_response.content_type).to include('javascript')
    end
  end

  it 'returns 404 for an unknown path' do
    get '/nope'
    expect(last_response.status).to eq(404)
  end
end
