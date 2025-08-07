require "active_support/testing/time_helpers"
require "time"

module RspecPower
  module Rails
    module TimeHelpers
      include ActiveSupport::Testing::TimeHelpers
    end
  end
end
