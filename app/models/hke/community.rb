module Hke
  class Community < Hke::ApplicationRecord
    belongs_to :account
    include Hke::Addressable
    include Hke::Preferring

    # Enum for community type
    enum community_type: {
      synagogue: "synagogue",
      school: "school"
    }

    validates :name, presence: true
    validates :community_type, presence: true

    before_save :ensure_account

    private

    # Ensure an account is created before saving the community
    def ensure_account
      self.account ||= Account.create!(name: name, personal: false)
    end
  end
end
