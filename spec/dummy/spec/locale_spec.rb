require_relative "#{__dir__}/rails_helper"

RSpec.describe "I18n" do
  it "uses the staging endpoint", with_locale: :en do
    expect(I18n.locale).to eq(:en)
  end

  it "uses the default locale when no locale is set", with_locale: :fr do
    expect(I18n.locale).to eq(:fr)
  end
end
