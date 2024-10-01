# spec/factories/deceased_people.rb
FactoryBot.define do
  factory :deceased_person, class: "Hke::DeceasedPerson" do
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    gender { ["male", "female"].sample }

    # Hebrew Date Fields
    hebrew_year_of_death { ["תשפ״א", "תשפ״ב", "תשפ״ג", "תשפ״ד"].sample }
    hebrew_month_of_death { ["תשרי", "חשוון", "כסלו", "טבת", "שבט", "אדר", "ניסן", "אייר", "סיון", "תמוז", "אב", "אלול"].sample }
    hebrew_day_of_death do
      day_of_month = rand(1..30)
      if day_of_month <= 10
        "א" * day_of_month
      else
        tens = ["י", "כ", "ל"][day_of_month / 10 - 1]
        units = ["", "א", "ב", "ג", "ד", "ה", "ו", "ז", "ח", "ט"][day_of_month % 10]
        tens + units
      end
    end

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

    factory :male_deceased_person, traits: [:male]
    factory :female_deceased_person, traits: [:female]
  end
end
