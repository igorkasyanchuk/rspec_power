require_relative "#{__dir__}/rails_helper"

RSpec.describe "RspecPower in a Rails app", :with_logs, type: :request do
  it "logs SQL for a simple request" do
    expect {
      get "/"
    }.to output(/Rendering home\/index.html/).to_stdout_from_any_process
  end

  it "logs SQL when :with_log_ar is set", :with_log_ar do
    expect {
      get "/"
    }.to output(/SELECT 1/).to_stdout_from_any_process
  end
end
