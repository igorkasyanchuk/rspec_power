require_relative "rails/time_helpers"

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
