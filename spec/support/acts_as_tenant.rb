RSpec.configure do |config|
  config.around(:each) do |example|
    community = FactoryBot.create(:community)
    ActsAsTenant.with_tenant(community) do
      example.run
    end
  end
end