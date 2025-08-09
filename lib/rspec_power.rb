require "rspec_power/version"
require "rspec_power/engine"
require "rspec_power/logging"
require "rspec_power/env"
require "rspec_power/i18n"
require "rspec_power/time"
require "rspec_power/ci"
require "rspec_power/sql"

RSpec.configure do |config|
  # Logging
  config.include RSpecPower::Rails::LoggingHelpers
  config.include_context "rspec_power::logging:verbose", with_log: true
  config.include_context "rspec_power::logging:verbose", with_logs: true
  config.include_context "rspec_power::logging:active_record", with_log_ar: true

  # Environment variable overrides
  config.include RSpecPower::Rails::EnvHelpers
  config.include_context "rspec_power::env:override", :with_env

  # I18n
  config.include RSpecPower::Rails::I18nHelpers
  config.include_context "rspec_power::i18n:dynamic", :with_locale

  # Time manipulation
  config.include RSpecPower::Rails::TimeHelpers
  config.include_context "rspec_power::time:freeze", :with_time_freeze
  config.include_context "rspec_power::time:zone", :with_time_zone

  # CI-only guards
  config.include_context "rspec_power::ci:only", :ci_only
  config.include_context "rspec_power::ci:skip", :skip_ci

  # SQL guards
  config.include RSpecPower::Rails::ActiveRecordHelpers
  config.include_context "rspec_power::sql:none", :with_no_sql_queries
  config.include_context "rspec_power::sql:must", :with_sql_queries
end
