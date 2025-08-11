require "active_support/testing/time_helpers"
require "time"

module RSpecPower
  module TimeHelpers
    include ActiveSupport::Testing::TimeHelpers

    # Prefer Timecop if it is available to avoid conflicts with
    # ActiveSupport::Testing::TimeHelpers and remove require-order dependency.
    def travel_to(time_value, &block)
      if defined?(Timecop)
        Timecop.freeze(time_value, &block)
      else
        super(time_value, &block)
      end
    end

    def with_time_zone(zone)
      if defined?(ActiveSupport::TimeZone)
        ::Time.use_zone(zone) { yield }
      else
        yield
      end
    end
  end
end

RSpec.shared_context "rspec_power::time:freeze" do
  around(:each) do |example|
    if ts = example.metadata[:with_time_freeze]
      ts = Time.parse(ts) if ts.is_a?(String)
      travel_to(ts) { example.run }
    else
      example.run
    end
  end
end

RSpec.shared_context "rspec_power::time:zone" do
  around(:each) do |example|
    if zone = example.metadata[:with_time_zone]
      with_time_zone(zone) { example.run }
    else
      example.run
    end
  end
end
