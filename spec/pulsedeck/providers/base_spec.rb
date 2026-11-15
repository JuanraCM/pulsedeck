# typed: false
# frozen_string_literal: true

RSpec.describe Pulsedeck::Providers::Base do
  it 'cannot be instantiated' do
    expect { described_class.new }.to raise_error(RuntimeError, /abstract/)
  end

  describe '#value' do
    let(:provider) do
      reading = self.reading
      Class.new(described_class) do
        define_method(:id) { 'alpha' }
        define_method(:label) { 'Alpha' }
        define_method(:unit) { 'W' }
        define_method(:read) { reading }
      end.new
    end

    context 'with a reading' do
      let(:reading) { 47.25 }

      it 'rounds the reading to one decimal' do
        expect(provider.value).to eq(47.3)
      end
    end

    context 'without a reading' do
      let(:reading) { nil }

      it 'returns nil' do
        expect(provider.value).to be_nil
      end
    end
  end
end
