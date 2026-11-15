# typed: false
# frozen_string_literal: true

RSpec.describe Pulsedeck::Components::Panel do
  it 'renders its title and block content', :aggregate_failures do
    html = described_class.new(title: 'My title').call { |panel| panel.plain 'My content' }
    expect(html).to include('My title')
    expect(html).to include('My content')
  end
end
