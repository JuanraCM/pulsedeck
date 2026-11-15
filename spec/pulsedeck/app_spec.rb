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
  end

  it 'returns 404 for an unknown path' do
    get '/nope'
    expect(last_response.status).to eq(404)
  end
end
