require "rails_helper"

RSpec.describe Hke::System, type: :model do
  include Hke::SystemInfoConcern

  before(:each) do
    # Clear the cache before each test to ensure no residual data affects the tests
    Hke::System.clear_system_info_cache
  end

  describe "SystemInfoConcern" do
    context "when accessing the system_info global structure" do
      it "returns correct values for product name and version, and no preferences" do
        # Create a System record with specific product name and version
        system = Hke::System.instance
        system.update(product_name: "Test Product", version: "1.0.0")

        # Add a debug line here
        puts "Preference before test: #{system.preference.inspect}"

        # Fetch system info using the concern method
        info = system_info

        # Assertions
        expect(info[:product_name]).to eq("Test Product")
        expect(info[:version]).to eq("1.0.0")
        expect(info[:preferences]).to be_nil
      end
    end

    context "when associating a new preference with the system" do
      it "returns the correct preferences" do
        # Create a System record
        system = Hke::System.instance
        system.update(product_name: "Test Product", version: "1.0.0")

        # Create and associate a new Preference record with the System
        system.create_preference(
          enable_send_email: false,
          enable_send_sms: false,
          how_many_days_before_yahrzeit_to_send_message: [2, 4, 6]
        )

        # Clear the cache and fetch updated system info
        Hke::System.clear_system_info_cache
        info = system_info

        # Assertions for system info
        expect(info[:product_name]).to eq("Test Product")
        expect(info[:version]).to eq("1.0.0")

        # Assertions for preferences
        preferences = info[:preferences]
        expect(preferences["enable_send_email"]).to be_falsey
        expect(preferences["enable_send_sms"]).to be_falsey
        expect(preferences["how_many_days_before_yahrzeit_to_send_message"]).to eq([2, 4, 6])
      end
    end
  end
end
