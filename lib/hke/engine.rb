module Hke
  class Engine < ::Rails::Engine
    isolate_namespace Hke
    config.autoload_paths << File.expand_path("../lib", __dir__)
    initializer 'hke.assets.precompile' do |app|
      app.config.assets.precompile += %w( hke/application.css )
    end
    # initializer 'hke.load_locale' do |app|
    #   app.config.i18n.load_path += Dir[File.join(root, 'config', 'locales', '**', '*.{rb,yml}')]
    # end
    
  end
end
