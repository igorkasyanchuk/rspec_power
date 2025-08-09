require_relative "rails/performance_helpers"

RSpec.shared_context "rspec_power::performance:maximum_execution_time" do
  around(:each) do |example|
    threshold = example.metadata[:with_maximum_execution_time]
    if threshold
      with_maximum_execution_time(threshold) { example.run }
    else
      example.run
    end
  end
end
