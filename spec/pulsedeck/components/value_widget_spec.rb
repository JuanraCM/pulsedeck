# typed: false
# frozen_string_literal: true

RSpec.describe Pulsedeck::Components::ValueWidget do
  let(:provider) do
    value = reading
    Class.new(Pulsedeck::Providers::Base) do
      define_method(:label) { 'Alpha' }
      define_method(:unit) { 'W' }
      define_method(:read) { value }
    end.new
  end
  let(:html) { described_class.new(provider: provider).call }

  context 'with a value' do
    let(:reading) { 47.25 }

    it 'renders the provider label, value and unit', :aggregate_failures do
      expect(html).to include('Alpha')
      expect(html).to include('47.2 W')
    end
  end

  context 'without a value' do
    let(:reading) { nil }

    it 'renders N/A' do
      expect(html).to include('N/A')
    end
  end
end
