module Hke
  class Engine < ::Rails::Engine
    isolate_namespace Hke

    # -------------------------------
    # Generators configuration
    # -------------------------------
    config.generators do |g|
      g.test_framework :rspec,
        fixtures: true,
        view_specs: false,
        helper_specs: false,
        routing_specs: false,
        controller_specs: false,
        request_specs: false
      g.fixture_replacement :factory_bot, dir: "spec/factories"
    end

    # -------------------------------
    # Autoload & Eager Load Paths
    # -------------------------------

    lib_path = root.join("lib")
    app_lib_path = root.join("app/lib")

    config.autoload_paths += [lib_path, app_lib_path, root.join("app/helpers")]
    config.eager_load_paths += [lib_path, app_lib_path] if Rails.env.production?

    # -------------------------------
    # Asset Precompilation
    # -------------------------------
    initializer "hke.assets.precompile" do |app|
      app.config.assets.precompile += %w[hke/application.css]
    end

    # -------------------------------
    # I18n Settings
    # -------------------------------
    config.i18n.available_locales = [:en, :he]
    config.i18n.default_locale = :he

    # Optional: enable deep locale loading if needed
    # initializer "hke.load_locales" do |app|
    #   app.config.i18n.load_path += Dir[root.join("config/locales/**/*.{rb,yml}")]
    # end
  end
end
