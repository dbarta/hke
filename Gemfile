source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

# Specify your gem's dependencies in hke.gemspec.
gemspec

gem "puma"

gem "pg"
gem "rack-cors"

gem "sprockets-rails"
gem "name_of_person", "~> 1.0"
gem "has_token"

# Start debugger with binding.b [https://github.com/ruby/debug]
# gem "debug", ">= 1.0.0"

gem "httparty"
gem "standard"

group :development, :test do
  gem "i18n-debug"
  gem "rspec-rails", "~> 6.1"
  gem "factory_bot_rails", "~> 6.0"
end
