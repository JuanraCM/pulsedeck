# typed: false
# frozen_string_literal: true

RSpec.describe Pulsedeck::Components::ValueWidget do
  let(:provider) do
    value = reading
    Class.new(Pulsedeck::Providers::Base) do
      define_method(:id) { 'alpha' }
      define_method(:label) { 'Alpha' }
      define_method(:unit) { 'W' }
      define_method(:read) { value }
    end.new
  end
  let(:html) { described_class.new(provider: provider).call }

  context 'with a value' do
    let(:reading) { 47.25 }

    it 'renders the provider label, value, unit and data attributes', :aggregate_failures do
      expect(html).to include('Alpha')
      expect(html).to include('47.3 W')
      expect(html).to include('data-metric="alpha"')
      expect(html).to include('data-unit="W"')
    end
  end

  context 'without a value' do
    let(:reading) { nil }

    it 'renders N/A' do
      expect(html).to include('N/A')
    end
  end
end
