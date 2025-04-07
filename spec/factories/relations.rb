# spec/factories/relations.rb
FactoryBot.define do
  factory :relation, class: "Hke::Relation" do
    association :contact_person, factory: :contact_person
    association :deceased_person, factory: :deceased_person
    association :community, factory: :community

    relation_of_deceased_to_contact do
      {
        father: "אבא",
        son: "בן",
        grandfather: "סבא",
        grandson: "נכד",
        uncle: "דוד",
        mother: "אמא",
        daughter: "בת",
        grandmother: "סבתא",
        granddaughter: "נכדה",
        aunt: "דודה",
        husband: "בעל",
        wife: "אשה",
        groom: "חתן",
        bride: "כלה",
        brother: "אח",
        sister: "אחות",
        brother_in_law: "גיס",
        sister_in_law: "גיסה",
        friend: "חבר",
        ex_wife: "גרושה",
        ex_husband: "גרוש"
    }.keys.sample.to_s
    end
  end
end
