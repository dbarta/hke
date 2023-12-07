require_relative "lib/hke/version"

Gem::Specification.new do |spec|
  spec.name        = "hke"
  spec.version     = Hke::VERSION
  spec.authors     = ["David Barta"]
  spec.email       = ["david@odeca.net"]
  spec.homepage    = "https://hke.com"
  spec.summary     = "Engine for Hakhel"
  spec.description = "Engine for Hakhel"
  spec.license     = "MIT"

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
end
