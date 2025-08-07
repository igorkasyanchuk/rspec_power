require "rspec_power/version"
require "rspec_power/engine"
require "rspec_power/logging"
require "rspec_power/env"
require "rspec_power/i18n"
require "rspec_power/time"

RSpec.configure do |config|
  config.include RspecPower::Rails::LoggingHelpers
  config.include_context "rspec_power::logging:verbose", log: true
  config.include_context "rspec_power::logging:active_record", log_ar: true

  config.include RspecPower::Rails::EnvHelpers
  config.include_context "rspec_power::env:override", :with_env

  config.include RspecPower::Rails::I18nHelpers
  config.include_context "rspec_power::i18n:dynamic", :with_locale

  config.include RspecPower::Rails::TimeHelpers
  config.include_context "rspec_power::time:freeze", :with_time_freeze
end
