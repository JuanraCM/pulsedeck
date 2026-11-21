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

    it 'renders the 7 panels of the default dashboard and the event stream script', :aggregate_failures do
      expect(last_response.body.scan('class="panel"').size).to eq(7)
      expect(last_response.body).to include("EventSource('/events')")
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
      expect(last_response.content_type).to include('text/plain')
      expect(last_response.body).to start_with("#{Pulsedeck::Config.path}: ")
      expect(last_response.body).not_to include('class="panel"')
    end
  end

  describe 'GET /events' do
    before do
      allow(Pulsedeck::EventStream).to receive(:new).and_wrap_original do |original, **args|
        original.call(**args).tap { |stream| allow(stream).to receive(:sleep).and_raise(StopIteration) }
      end
      get '/events'
    end

    it 'streams the metric values as server-sent events', :aggregate_failures do
      expect(last_response.status).to eq(200)
      expect(last_response.content_type).to include('text/event-stream')
      expect(last_response.body).to start_with('data: {"cpu_temperature":')
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

  it 'returns 404 for an unknown path' do
    get '/nope'
    expect(last_response.status).to eq(404)
  end
end
