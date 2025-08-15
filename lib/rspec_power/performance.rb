module RSpecPower
  module PerformanceHelpers
      # Ensures the given block completes within the specified duration (milliseconds).
      # Raises RSpec::Expectations::ExpectationNotMetError if the threshold is exceeded.
      def with_maximum_execution_time(max_duration_ms)
        raise ArgumentError, "with_maximum_execution_time requires a block" unless block_given?

        max_ms = max_duration_ms.to_f
        start_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)
        yield
      ensure
        elapsed_ms = (Process.clock_gettime(Process::CLOCK_MONOTONIC) - start_time) * 1000.0
        # Do not override an existing exception
        if $!.nil? && elapsed_ms > max_ms
          formatted_elapsed = format("%.3f", elapsed_ms)
          formatted_limit = format("%.3f", max_ms)
          raise RSpec::Expectations::ExpectationNotMetError,
                "Execution time exceeded: #{formatted_elapsed}ms > #{formatted_limit}ms"
        end
      end
  end
end

RSpec.shared_context "rspec_power::performance:maximum_execution_time" do
  around(:each) do |example|
    threshold = example.metadata[:with_maximum_execution_time]
    if threshold
      with_maximum_execution_time(threshold) { example.run }
    else
      example.run
    end
  end
end
