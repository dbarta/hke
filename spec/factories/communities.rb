FactoryBot.define do
  factory :community, class: "Hke::Community" do
    association :account, factory: :account
    name { "Kfar Vradim Main Sybagogue" }
    community_type { "synagogue" }

    after(:build) do |community|
      community.preference = build(:community_preference)
      community.address = build(:address)
    end
  end
end
