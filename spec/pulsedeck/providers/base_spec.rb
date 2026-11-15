# typed: false
# frozen_string_literal: true

RSpec.describe Pulsedeck::Providers::Base do
  it 'cannot be instantiated' do
    expect { described_class.new }.to raise_error(RuntimeError, /abstract/)
  end
end
