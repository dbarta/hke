# config/initializers/cors.rb
Rails.application.config.middleware.insert_before 0, Rack::Cors do
    puts "@@@@@@@@@@@ CORS Initializing"
    allow do
      origins '*', 'localhost:3000', '127.0.0.1:3000'
        resource '*',
        headers: :any,
        methods: [:get, :post, :put, :delete, :options]
    end
  end
  