# spec/support/setup.rb
module UserAndCommunitySetup
  extend FactoryBot::Syntax::Methods
  def self.setup_system_and_community
    # Create system with factory
    create(:system)

    # Create admin user and account with factories
    admin_user = create(:user, :admin)
    account = create(:account, owner: admin_user)

    # Create community with preferences and address using the existing factories
    community = create(:community, account: account)

    # Set the current tenant for multi-tenancy
    ActsAsTenant.current_tenant = community
  end
end
