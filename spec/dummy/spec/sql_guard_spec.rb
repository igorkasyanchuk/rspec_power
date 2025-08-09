require_relative "#{__dir__}/rails_helper"

RSpec.describe "SQL guard" do
  it "allows blocks with no SQL" do
    expect_no_sql do
      # pure in-memory operations
      sum = (1..100).sum
      expect(sum).to eq(5050)
    end
  end

  it "fails when SQL occurs" do
    expect {
      expect_no_sql do
        ActiveRecord::Base.connection.execute("SELECT 1")
      end
    }.to raise_error(RSpec::Expectations::ExpectationNotMetError, /Expected no SQL/)
  end

  context ":with_no_sql_queries", :with_no_sql_queries do
    it "does nothing when no queries are made" do
      expect { 2 + 2 }.not_to raise_error
    end
  end

  context ":with_sql_queries", :with_sql_queries do
    it "passes when at least one query is made" do
      expect {
        ActiveRecord::Base.connection.execute("SELECT 1")
      }.not_to raise_error
    end
  end
end
