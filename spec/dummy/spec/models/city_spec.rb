require_relative "#{__dir__}/../rails_helper"

RSpec.describe City, type: :model do
  it "can check if sql was executed" do
    expect_sql do
      City.create(name: "New York")
    end
  end
end
