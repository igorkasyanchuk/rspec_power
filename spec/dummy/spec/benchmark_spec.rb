require_relative "#{__dir__}/rails_helper"

RSpec.describe "Benchmark helper", with_benchmark: { runs: 3 } do
  it "wraps the example and records results" do
    10_000.times { 1 + 1 }
  end
end
