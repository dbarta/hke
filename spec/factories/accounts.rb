FactoryBot.define do
  factory :account do
    name { Faker::Company.name }
    association :owner, factory: :user
    personal { false }
    billing_email { Faker::Internet.email }

    trait :with_billing_info do
      extra_billing_info { Faker::Company.catch_phrase }
    end

    trait :kfar_vradim do
      name { "Kfar Vradim" }
      association :owner, factory: :user
      personal { false }
      billing_email { "david@odeca.net" }
    end
  end
end
