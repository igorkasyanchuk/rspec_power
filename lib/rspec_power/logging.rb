RSpec.shared_context "rspec_power::logging:verbose" do
  around(:each) do |ex|
    if ex.metadata[:log] == true || ex.metadata[:log] == :all
      with_logging(&ex)
    else
      ex.call
    end
  end
end

RSpec.shared_context "rspec_power::logging:active_record" do
  around(:each) do |ex|
    if ex.metadata[:log_ar]
      with_ar_logging(&ex)
    else
      ex.call
    end
  end
end
