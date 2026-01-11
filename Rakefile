dummy_rakefile = File.expand_path("test/dummy/Rakefile", __dir__)
stub_rakefile  = File.expand_path("test/app_stub.Rakefile", __dir__)

APP_RAKEFILE = File.exist?(dummy_rakefile) ? dummy_rakefile : stub_rakefile

load "rails/tasks/engine.rake"
load "rails/tasks/statistics.rake"
require "bundler/gem_tasks"
