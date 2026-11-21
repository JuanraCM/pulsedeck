# typed: false
# frozen_string_literal: true

RSpec.describe Pulsedeck::Components::Grid do
  it 'renders the track template and its block', :aggregate_failures do
    html = described_class.new(columns: 4, rows: 3).call { |grid| grid.plain 'Inside' }
    expect(html).to include('class="grid"')
    expect(html).to include('grid-template-columns: repeat(4, 1fr)')
    expect(html).to include('grid-template-rows: repeat(3, 1fr)')
    expect(html).to include('Inside')
  end
end
