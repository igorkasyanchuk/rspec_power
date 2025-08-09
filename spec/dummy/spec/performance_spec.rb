require_relative "#{__dir__}/rails_helper"

RSpec.describe "Performance guard" do
  it "passes when under threshold" do
    expect {
      with_maximum_execution_time(5) do
        # Trivial work
        10.times { 1 + 1 }
      end
    }.not_to raise_error
  end

  it "fails when over threshold" do
    expect {
      with_maximum_execution_time(1) do
        sleep 0.005 # 5ms
      end
    }.to raise_error(RSpec::Expectations::ExpectationNotMetError, /Execution time exceeded/)
  end

  context ":with_maximum_execution_time", with_maximum_execution_time: 5 do
    it "wraps examples via metadata" do
      expect { 1 + 1 }.not_to raise_error
    end
  end
end
