require "bundler/setup"

APP_RAKEFILE = File.expand_path("spec/dummy/Rakefile", __dir__)

require "bundler/gem_tasks"

require "rspec/core/rake_task"

# plugin’s own specs
RSpec::Core::RakeTask.new(:spec)

# dummy app specs
namespace :dummy do
  desc "Run dummy Rails app specs"
  task :spec do
    Dir.chdir("spec/dummy") { sh "bundle exec rspec" }
  end
end

task default: [ :spec, "dummy:spec" ]
