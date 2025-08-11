module RSpecPower
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
          max_ms: timings_ms.max
        }

        BenchmarkHelpers.add_result(summary)
        summary
      end
  end
end

# Shared context to configure benchmark with metadata
RSpec.shared_context "rspec_power::benchmark:run" do
  around(:each) do |example|
    opts = example.metadata[:with_benchmark]
    if opts
      runs = (opts[:runs] || 1).to_i
      label = example.full_description
      extend RSpecPower::BenchmarkHelpers
      __run_benchmark__(runs: runs, label: label) { example.run }
    else
      example.run
    end
  end
end

# Print a consolidated report after the suite finishes
RSpec.configure do |config|
  config.after(:suite) do
    results = RSpecPower::BenchmarkHelpers.results
    next if results.empty?

    puts "\nBenchmark results (rspec_power):"
    results.each do |r|
      puts "- #{r[:label]}: runs=#{r[:runs]} avg=#{format('%.3f', r[:avg_ms])}ms min=#{format('%.3f', r[:min_ms])}ms max=#{format('%.3f', r[:max_ms])}ms"
    end
  end
end
