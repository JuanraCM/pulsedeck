# typed: false
# frozen_string_literal: true

RSpec.describe Pulsedeck::Placement do
  it 'defaults width and height to 1', :aggregate_failures do
    placement = described_class.new(column: 2, row: 3)
    expect(placement.width).to eq(1)
    expect(placement.height).to eq(1)
  end

  %i[column row width height].each do |field|
    it "rejects 0 for #{field}" do
      args = { column: 1, row: 1, width: 1, height: 1, field => 0 }
      expect { described_class.new(**args) }.to raise_error(ArgumentError)
    end
  end
end
