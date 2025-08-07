require "rspec_power/version"
require "rspec_power/engine"
require "rspec_power/rails/logging_helpers"
require "rspec_power/logging"

RSpec.configure do |config|
  config.include RspecPower::Rails::LoggingHelpers

  config.include_context "rspec_power::logging:verbose",       log: true
  config.include_context "rspec_power::logging:active_record", log_ar: true
end
