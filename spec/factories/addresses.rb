FactoryBot.define do
  factory :address, class: "::Address" do
    line1 { Faker::Address.street_address } # -> # Internal @attributes[:line1] = Proc.new { "sunshine" }

    line2 { Faker::Address.secondary_address }
    city { Faker::Address.city }
    state { Faker::Address.state_abbr }
    postal_code { Faker::Address.zip_code }
    country { "Israel" }
    address_type { :shipping }
    # association :addressable, factory: :community
  end
end
