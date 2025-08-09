RSpec.shared_context "rspec_power::ci:only" do
  around(:each) do |example|
    ci = ENV["CI"].to_s.downcase
    if ci == "" || ci == "false" || ci == "0"
      skip "Skipped in non-CI environment"
    else
      example.run
    end
  end
end

RSpec.shared_context "rspec_power::ci:skip" do
  around(:each) do |example|
    ci = ENV["CI"].to_s.downcase
    if ci != "" && ci != "false" && ci != "0"
      skip "Skipped in CI environment"
    else
      example.run
    end
  end
end
