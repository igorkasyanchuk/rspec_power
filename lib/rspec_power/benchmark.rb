require_relative "rails/benchmark_helpers"

# Shared context to configure benchmark with metadata
RSpec.shared_context "rspec_power::benchmark:run" do
  around(:each) do |example|
    opts = example.metadata[:with_benchmark]
    if opts
      runs = (opts[:runs] || 1).to_i
      label = example.full_description
      extend RSpecPower::Rails::BenchmarkHelpers
      __run_benchmark__(runs: runs, label: label) { example.run }
    else
      example.run
    end
  end
end

# Print a consolidated report after the suite finishes
RSpec.configure do |config|
  config.after(:suite) do
    results = RSpecPower::Rails::BenchmarkHelpers.results
    next if results.empty?

    puts "\nBenchmark results (rspec_power):"
    results.each do |r|
      puts "- #{r[:label]}: runs=#{r[:runs]} avg=#{format('%.3f', r[:avg_ms])}ms min=#{format('%.3f', r[:min_ms])}ms max=#{format('%.3f', r[:max_ms])}ms"
    end
  end
end
