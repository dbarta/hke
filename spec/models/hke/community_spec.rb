require "rails_helper"
# /Users/dbarta/Dropbox/Apps/web_apps/rails_apps/apps/hke/spec/models/hke/community_spec.rb
RSpec.describe Hke::Community, type: :model do
  let(:admin_user) { create(:user, :admin) }
  let(:account) { create(:account, :kfar_vradim, owner: admin_user) }

  context "creating a synagogue with address and preferences" do
    it "creates a synagogue with valid address and preferences" do
      community = create(:community, account: account)

      # Assertions for the community
      expect(community).to be_valid
      expect(community.name).to eq("Kfar Vradim Main Sybagogue")
      expect(community.community_type).to eq("synagogue")

      expect(community.address).to be_present
      expect(community.address.line1).to be_present
      expect(community.address.city).to be_present
      expect(community.address.state).to be_present
      expect(community.address.postal_code).to be_present
      expect(community.address.address_type).to be_present
      expect(community.address.country).to eq("Israel")

      # Assertions for the preferences
      expect(community.preference).to be_present
      expect(community.preference.enable_send_email).to be(true)
      expect(community.preference.enable_send_sms).to be(false)
      expect(community.preference.how_many_days_before_yahrzeit_to_send_message).to be_present
      expect(community.preference.attempt_to_resend_if_no_sent_on_time).to be(true)
    end
  end
end
