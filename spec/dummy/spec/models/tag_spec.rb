require_relative "#{__dir__}/../rails_helper"

RSpec.describe Tag, type: :model do
  it "can check if sql was not executed" do
    expect_no_sql do
      Tag.new
    end
  end
end
