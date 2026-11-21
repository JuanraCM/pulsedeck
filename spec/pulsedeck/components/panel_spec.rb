# typed: false
# frozen_string_literal: true

RSpec.describe Pulsedeck::Components::Panel do
  let(:placement) { Pulsedeck::Placement.new(column: 2, row: 1, width: 2) }

  it 'renders its title and block content', :aggregate_failures do
    html = described_class.new(title: 'My title', placement: placement).call { |panel| panel.plain 'My content' }
    expect(html).to include('My title')
    expect(html).to include('My content')
  end

  it 'renders its grid position' do
    html = described_class.new(title: 'T', placement: placement).call { |panel| panel.plain 'x' }
    expect(html).to include('grid-column: 2 / span 2; grid-row: 1 / span 1')
  end
end
