# typed: false
# frozen_string_literal: true

ENV['APP_ENV'] = 'test'

require 'rack/test'
require 'tmpdir'
require_relative '../lib/pulsedeck'
require_relative 'support/fake_hwmon'

RSpec.configure do |config|
  config.include Rack::Test::Methods
  config.expect_with(:rspec) { |c| c.syntax = :expect }
  config.include FakeHwmon
  FakeHwmon.setup(config)

  # Specs must never read or write the real config file.
  config.around do |example|
    original = Dir.home
    Dir.mktmpdir do |home|
      ENV['HOME'] = home
      example.run
    ensure
      ENV['HOME'] = original
    end
  end
end
