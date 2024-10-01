FactoryBot.define do
  factory :user do
    email { Faker::Internet.email }
    password { "password" }
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    terms_of_service { true }

    trait :admin do
      admin { true }
      email { "david@odeca.net" }
      password { "odeca111" }
      first_name { "David" }
      last_name { "Barta" }
    end
  end
end
