# typed: false
# frozen_string_literal: true

RSpec.describe Pulsedeck::EventStream do
  define_method(:fake_provider) do |id, reading|
    Class.new(Pulsedeck::Providers::Base) do
      define_method(:id) { id }
      define_method(:label) { id }
      define_method(:unit) { 'W' }
      define_method(:read) { reading }
    end.new
  end

  let(:stream) do
    described_class.new(providers: [fake_provider('alpha', 47.25), fake_provider('beta', nil)], interval: 0)
  end

  it 'sends one message with all values for each interval', :aggregate_failures do
    frames = stream.to_enum(:each).first(2)
    expect(frames.size).to eq(2)
    expect(frames).to all(start_with('data: ').and(end_with("\n\n")))
    expect(frames.map { |frame| JSON.parse(frame.delete_prefix('data: ')) }).to all(eq('alpha' => 47.3, 'beta' => nil))
  end
end
