module Hke
  class Engine < ::Rails::Engine
    isolate_namespace Hke

    config.generators do |g|
      g.test_framework :rspec,
        fixtures: true,
        view_specs: false,
        helper_specs: false,
        routing_specs: false,
        controller_specs: false,
        request_specs: false
      g.fixture_replacement :factory_bot, dir: "spec/factories" # If using FactoryBot
    end

    config.autoload_paths << File.expand_path("../lib", __dir__)
    config.eager_load_paths << File.expand_path("../lib", __dir__)

    initializer "hke.assets.precompile" do |app|
      app.config.assets.precompile += %w[hke/application.css]
    end
    # initializer 'hke.load_locale' do |app|
    #   app.config.i18n.load_path += Dir[File.join(root, 'config', 'locales', '**', '*.{rb,yml}')]
    # end
    # Permitted locales available for the application
    config.i18n.available_locales = [:en, :he]

    # Set default locale
    config.i18n.default_locale = :he
  end
end
