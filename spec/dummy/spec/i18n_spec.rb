require_relative "#{__dir__}/rails_helper"

RSpec.describe "Account", with_time_freeze: "2025-01-01 00:00:00", with_time_zone: "Pacific Time (US & Canada)" do
  it "calculates expiry from the new year" do
    expect(Account.current_date).to eq(Date.new(2025, 1, 1))
  end

  it "schedules the job correctly" do
    expect(Account.current_time).to eq(Time.new(2025, 1, 1, 0, 0, 0))
  end

  it "applies the configured time zone inside examples" do
    expect(Time.zone.name).to eq("Pacific Time (US & Canada)")
  end
end
