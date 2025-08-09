require_relative "rails/logging_helpers"

RSpec.shared_context "rspec_power::logging:verbose" do
  around(:each) do |ex|
    if ex.metadata[:with_log] == true || ex.metadata[:with_log] == :all ||
       ex.metadata[:with_logs] == true || ex.metadata[:with_logs] == :all
      with_logging(&ex)
    else
      ex.call
    end
  end
end

RSpec.shared_context "rspec_power::logging:active_record" do
  around(:each) do |ex|
    if ex.metadata[:with_log_ar]
      with_ar_logging(&ex)
    else
      ex.call
    end
  end
end
