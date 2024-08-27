require_relative "lib/hke/version"

Gem::Specification.new do |spec|
  spec.name = "hke"
  spec.version = Hke::VERSION
  spec.authors = ["David Barta"]
  spec.email = ["david@odeca.net"]
  spec.homepage = "https://hke.com"
  spec.summary = "Engine for Hakhel"
  spec.description = "Engine for Hakhel"
  spec.license = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the "allowed_push_host"
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  spec.metadata["allowed_push_host"] = "http://hke.com"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "http://hke.com"
  spec.metadata["changelog_uri"] = "http://hke.com"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  end

  spec.add_dependency "rails", ">= 7.1.2"
  spec.add_dependency "httparty"
  spec.add_dependency "has_secure_token", "~> 1.0"
  spec.add_dependency "validates_timeliness", "~> 6.0", ">= 6.0.1"

  spec.add_development_dependency "rspec-rails", "~> 6.1"
  spec.add_development_dependency "factory_bot_rails", "~> 6.0"
  spec.add_development_dependency "database_cleaner-active_record", "~> 2.0"
  spec.add_development_dependency "shoulda-matchers", "~> 5.0"
  spec.add_development_dependency "faker", "~> 2.18"
  spec.add_development_dependency "rack-test"
end
