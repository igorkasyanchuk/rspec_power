require_relative "rails/active_record_helpers"

RSpec.shared_context "rspec_power::sql:none" do
  around(:each) do |example|
    executed_sql = []

    callback = lambda do |_name, _started, _finished, _unique_id, payload|
      event_name = payload[:name].to_s
      cached = payload[:cached]
      next if cached
      next if event_name == "SCHEMA" || event_name == "TRANSACTION"

      executed_sql << payload[:sql]
    end

    ActiveSupport::Notifications.subscribed(callback, "sql.active_record") do
      example.run
    end

    if executed_sql.any?
      message = "Expected no SQL to be executed, but #{executed_sql.length} statement(s) were run.\n" \
                + executed_sql.map { |sql| "  - #{sql}" }.join("\n")
      raise RSpec::Expectations::ExpectationNotMetError, message
    end
  end
end

RSpec.shared_context "rspec_power::sql:must" do
  around(:each) do |example|
    executed_sql = []

    callback = lambda do |_name, _started, _finished, _unique_id, payload|
      event_name = payload[:name].to_s
      cached = payload[:cached]
      next if cached
      next if event_name == "SCHEMA" || event_name == "TRANSACTION"

      executed_sql << payload[:sql]
    end

    ActiveSupport::Notifications.subscribed(callback, "sql.active_record") do
      example.run
    end

    if executed_sql.empty?
      raise RSpec::Expectations::ExpectationNotMetError, "Expected some SQL to be executed, but none was run"
    end
  end
end
