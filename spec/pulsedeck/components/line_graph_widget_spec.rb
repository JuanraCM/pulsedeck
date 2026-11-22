# typed: false
# frozen_string_literal: true

RSpec.describe Pulsedeck::Components::LineGraphWidget do
  let(:html) { described_class.new(provider: provider, placement: placement, readings: 5).call }
  let(:placement) { Pulsedeck::Placement.new(column: 1, row: 1) }
  let(:provider) do
    Class.new(Pulsedeck::Providers::Base) do
      define_method(:id) { 'alpha' }
      define_method(:label) { 'Alpha' }
      define_method(:unit) { 'W' }
      define_method(:read) { 1.0 }
    end.new
  end

  it 'is a widget' do
    expect(described_class).to be < Pulsedeck::Components::Widget
  end

  it 'renders the label and a canvas with the graph data attributes', :aggregate_failures do
    expect(html).to include('Alpha', '<canvas', 'data-graph="alpha"', 'data-readings="5"', 'data-unit="W"')
    expect(html).not_to include('<canvas data-metric', 'data-metric="alpha" data-graph')
  end

  it 'renders the current value in a live-updated span', :aggregate_failures do
    expect(html).to include('<span class="value" data-metric="alpha" data-unit="W">1.0 W</span>')
  end

  it 'uses 60 readings by default' do
    expect(described_class.new(provider: provider, placement: placement).readings).to eq(60)
  end

  it 'raises when readings is less than 2' do
    expect { described_class.new(provider: provider, placement: placement, readings: 1) }
      .to raise_error(ArgumentError, 'readings must be 2 or more')
  end
end
