# This file is copied to spec/ when you run 'rails generate rspec:install'
puts "Loading engine's rails_helper.rb"

require "spec_helper"
require "hke"
ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require File.expand_path("../../config/environment", __FILE__)
# Prevent database truncation if the environment is production
abort("The Rails environment is running in production mode!") if Rails.env.production?
require "rspec/rails"

# Dir[File.expand_path("support/**/*.rb", __dir__)].each { |f| require f }
Dir[File.expand_path("support/**/*.rb", __dir__)].each do |f|
  puts "Requiring: #{f}"  # Add this line for debugging
  require f
end
Dir[Rails.root.join("spec", "support", "**", "*.rb")].sort.each { |f| require f }

# Checks for pending migrations and applies them before tests are run.
# If you are not using ActiveRecord, you can remove these lines.
begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  puts e.to_s.strip
  exit 1
end
RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods
  config.fixture_paths = ["#{::Rails.root}/spec/fixtures"]
  config.use_transactional_fixtures = true
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!
  # Ensure FactoryBot loads factories from the Hke engine
  FactoryBot.definition_file_paths = [Hke::Engine.root.join("spec/factories")]
  FactoryBot.find_definitions
end
