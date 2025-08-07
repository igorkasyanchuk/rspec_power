require_relative "#{__dir__}/rails_helper"

RSpec.describe Account do
  it "uses the staging endpoint", with_env: { "API_URL" => "https://staging.example.com" } do
    expect(Account.endpoint).to eq("https://staging.example.com")
  end

  it "removes a key when set to nil", with_env: { "FEATURE_X_ENABLED" => nil } do
    expect(ENV).not_to have_key("FEATURE_X_ENABLED")
  end
end
