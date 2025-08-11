module RSpecPower
  module Rails
    module BenchmarkHelpers
      class << self
        def results_registry
          @results_registry ||= []
        end

        def add_result(result)
          results_registry << result
        end

        def results
          results_registry.dup
        end
      end

      # Internal: run the given block multiple times and record a summary.
      # Used by the shared context, not exposed as a public helper anymore.
      def __run_benchmark__(runs: 1, label:)
        raise ArgumentError, "__run_benchmark__ requires a block" unless block_given?

        iterations = runs.to_i
        raise ArgumentError, "runs must be >= 1" if iterations < 1

        timings_ms = []
        iterations.times do
          start = Process.clock_gettime(Process::CLOCK_MONOTONIC)
          yield
          finish = Process.clock_gettime(Process::CLOCK_MONOTONIC)
          timings_ms << (finish - start) * 1000.0
        end

        avg = timings_ms.sum / timings_ms.length
        summary = {
          label: label,
          runs: iterations,
          avg_ms: avg,
          min_ms: timings_ms.min,
          max_ms: timings_ms.max,
        }

        BenchmarkHelpers.add_result(summary)
        summary
      end
    end
  end
end
