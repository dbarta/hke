module Hke
  class Engine < ::Rails::Engine
    isolate_namespace Hke
    config.autoload_paths << File.expand_path("../lib", __dir__)
  end
end
