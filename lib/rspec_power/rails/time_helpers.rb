require "active_support/testing/time_helpers"
require "time"

module RSpecPower
  module Rails
    module TimeHelpers
      include ActiveSupport::Testing::TimeHelpers

      def with_time_zone(zone)
        if defined?(ActiveSupport::TimeZone)
          ::Time.use_zone(zone) { yield }
        else
          yield
        end
      end
    end
  end
end
