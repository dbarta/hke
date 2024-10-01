# spec/models/hke/deceased_person_spec.rb
require "rails_helper"

RSpec.describe Hke::DeceasedPerson, type: :model do
  it "creates a deceased person with valid Hebrew date and associated contacts" do
    contact_person1 = create(:male_contact_person)
    contact_person2 = create(:female_contact_person)
    deceased_person = create(:male_deceased_person, relations: [
      build(:relation, contact_person: contact_person1),
      build(:relation, contact_person: contact_person2)
    ])

    # Verify the Hebrew date components are correctly generated
    expect(deceased_person.hebrew_year_of_death).not_to be_nil
    expect(deceased_person.hebrew_month_of_death).not_to be_nil
    expect(deceased_person.hebrew_day_of_death).not_to be_nil

    # Verify the Gregorian date of death is automatically calculated
    expect(deceased_person.date_of_death).not_to be_nil

    # Verify the relations were created
    expect(deceased_person.relations.count).to eq(2)
    expect(deceased_person.relations.map(&:contact_person)).to include(contact_person1, contact_person2)

    # Verify future messages were created
    deceased_person.relations.each do |relation|
      expect(relation.future_messages.count).to be > 0
    end
  end
end
