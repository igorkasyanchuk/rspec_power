require_relative "lib/rspec_power/version"

Gem::Specification.new do |spec|
  spec.name        = "rspec_power"
  spec.version     = RspecPower::VERSION
  spec.authors     = [ "Igor Kasyanchuk" ]
  spec.email       = [ "igorkasyanchuk@gmail.com" ]
  spec.homepage    = "TODO"
  spec.summary     = "RSpec power tools"
  spec.description = "RSpec power tools"
  spec.license     = "MIT"


  spec.metadata["homepage_uri"] = spec.homepage

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  end

  spec.add_dependency "rails"
  spec.add_dependency "rspec"
  spec.add_dependency "rspec-rails"
  spec.add_development_dependency "debug"
end
