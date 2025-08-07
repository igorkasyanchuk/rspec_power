require_relative "rails/env_helpers"

RSpec.shared_context "rspec_power::env:override" do
  around(:each) do |example|
    overrides = example.metadata[:with_env] || {}
    with_test_env(overrides) { example.run }
  end
end
