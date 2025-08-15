require "time"

module RSpecPower
  module TimeHelpers
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
      # include ActiveSupport::Testing::TimeHelpers if not already included
      if !@_rspec_power_time_helpers_included && !respond_to?(:travel_to)
        RSpec.configure do |config|
          config.include ActiveSupport::Testing::TimeHelpers
        end
        @_rspec_power_time_helpers_included = true
      end
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
