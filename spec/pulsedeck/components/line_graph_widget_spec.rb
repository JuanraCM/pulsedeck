# typed: false
# frozen_string_literal: true

RSpec.describe Pulsedeck::Components::LineGraphWidget do
  let(:provider) do
    Class.new(Pulsedeck::Providers::Base) do
      define_method(:id) { 'alpha' }
      define_method(:label) { 'Alpha' }
      define_method(:unit) { 'W' }
      define_method(:read) { 1.0 }
    end.new
  end
  let(:placement) { Pulsedeck::Placement.new(column: 1, row: 1) }
  let(:html) { described_class.new(provider: provider, placement: placement, readings: 5).call }

  it 'renders the label and a canvas with the graph data attributes', :aggregate_failures do
    expect(html).to include('Alpha', '<canvas', 'data-graph="alpha"', 'data-readings="5"', 'data-unit="W"')
    expect(html).not_to include('data-metric')
  end

  it 'uses 60 readings by default' do
    expect(described_class.new(provider: provider, placement: placement).readings).to eq(60)
  end

  it 'raises when readings is less than 2' do
    expect { described_class.new(provider: provider, placement: placement, readings: 1) }
      .to raise_error(ArgumentError, 'readings must be 2 or more')
  end
end
