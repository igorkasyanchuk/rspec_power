module RSpecPower
  module Rails
    module ActiveRecordHelpers
      # Fails the example if any SQL is executed within the provided block.
      # Ignores cached, schema, and transaction events to avoid false positives.
      def expect_no_sql
        raise ArgumentError, "expect_no_sql requires a block" unless block_given?

        executed_sql_statements = capture_executed_sql { yield }

        if executed_sql_statements.any?
          message = "Expected no SQL to be executed, but #{executed_sql_statements.length} statement(s) were run.\n" \
                    + executed_sql_statements.map { |sql| "  - #{sql}" }.join("\n")
          raise RSpec::Expectations::ExpectationNotMetError, message
        end
      end

      # Passes only if at least one SQL statement is executed within the block.
      # Ignores cached, schema, and transaction events to avoid false positives.
      def expect_sql
        raise ArgumentError, "expect_sql requires a block" unless block_given?

        executed_sql_statements = capture_executed_sql { yield }

        if executed_sql_statements.empty?
          raise RSpec::Expectations::ExpectationNotMetError,
                "Expected some SQL to be executed, but none was run"
        end
      end

      private

      # Subscribes to ActiveRecord SQL notifications and captures relevant statements
      # executed within the given block. Returns an Array of SQL strings.
      def capture_executed_sql
        raise ArgumentError, "capture_executed_sql requires a block" unless block_given?

        executed_sql_statements = []

        notification_callback = lambda do |_name, _started, _finished, _unique_id, payload|
          event_name = payload[:name].to_s
          is_cached_event = payload[:cached]

          # Skip noise that doesn't represent user-level SQL
          next if is_cached_event
          next if event_name == "SCHEMA" || event_name == "TRANSACTION"

          executed_sql_statements << payload[:sql]
        end

        ActiveSupport::Notifications.subscribed(notification_callback, "sql.active_record") do
          yield
        end

        executed_sql_statements
      end
    end
  end
end
