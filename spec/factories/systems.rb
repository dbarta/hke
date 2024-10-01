FactoryBot.define do
  factory :system, class: "Hke::System" do
    product_name { "Hakhel" }
    version { "1.0" }

    after(:build) do |system|
      system.preference = build(:system_preference)
    end
  end
end
