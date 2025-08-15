require_relative "lib/rspec_power/version"

Gem::Specification.new do |spec|
  spec.name        = "rspec_power"
  spec.version     = RSpecPower::VERSION
  spec.authors     = [ "Igor Kasyanchuk" ]
  spec.email       = [ "igorkasyanchuk@gmail.com" ]
  spec.homepage    = "https://github.com/igorkasyanchuk/rspec_power"
  spec.summary     = "Powerful RSpec helpers for Rails testing"
  spec.description = "A collection of helpers and contexts to enhance Rails specs: logging, env/I18n/time helpers, SQL guards, request/DB dumps, benchmarking, CI guards, and performance limits."
  spec.license     = "MIT"


  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/igorkasyanchuk/rspec_power"
  spec.metadata["bug_tracker_uri"] = "https://github.com/igorkasyanchuk/rspec_power/issues"
  spec.metadata["documentation_uri"] = "https://github.com/igorkasyanchuk/rspec_power#readme"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  end

  spec.add_dependency "rails"
  spec.add_dependency "rspec"
  spec.add_dependency "rspec-rails"
  spec.add_dependency "csv"
  spec.add_development_dependency "debug"
end
