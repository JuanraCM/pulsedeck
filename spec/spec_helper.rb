ENV["APP_ENV"] = "test"

require "rack/test"
require_relative "../lib/pulsedeck"

RSpec.configure do |config|
  config.include Rack::Test::Methods
  config.expect_with(:rspec) { |c| c.syntax = :expect }
end
