# spec/factories/contact_people.rb
FactoryBot.define do
  factory :contact_person, class: "Hke::ContactPerson" do
    association :community, factory: :community
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    gender { ["male", "female"].sample }
    phone { Faker::PhoneNumber.unique.cell_phone_in_e164 }

    trait :male do
      first_name { ["יוסף", "אברהם", "משה", "דוד", "אהרון"].sample }
      last_name { ["כהן", "לוי", "מזרחי", "עזריאל", "אלמוג"].sample }
      gender { "male" }
    end

    trait :female do
      first_name { ["שרה", "רבקה", "לאה", "חנה", "מרים"].sample }
      last_name { ["כהן", "לוי", "מזרחי", "עזריאל", "אלמוג"].sample }
      gender { "female" }
    end

    factory :male_contact_person, traits: [:male]
    factory :female_contact_person, traits: [:female]
  end
end
