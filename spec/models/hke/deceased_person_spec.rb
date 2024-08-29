require "rails_helper"

RSpec.describe Hke::DeceasedPerson, type: :model do
  it { should have_many(:relations).dependent(:destroy) }
  it { should have_many(:contact_people).through(:relations) }
  it { should belong_to(:cemetery).optional }

  it { should validate_presence_of(:first_name).with_message(:presence) }
  it { should validate_presence_of(:last_name).with_message(:presence) }
  it { should validate_presence_of(:gender).with_message(:presence) }
  it { should validate_presence_of(:hebrew_year_of_death).with_message(:presence) }
  it { should validate_presence_of(:hebrew_month_of_death).with_message(:presence) }
  it { should validate_presence_of(:hebrew_day_of_death).with_message(:presence) }

  it do
    should validate_inclusion_of(:gender)
      .in_array(["male", "female"])
      .with_message(:gender_invalid)
  end

  it { should accept_nested_attributes_for(:relations).allow_destroy(true).reject_if(:all_blank) }

  describe "#contact_name" do
    it "returns empty string if there are no relations" do
      deceased_person = build(:deceased_person)
      expect(deceased_person.contact_name).to eq("")
    end

    it "returns the first contact name if relations exist" do
      contact = create(:contact_person, first_name: "John", last_name: "Doe")
      deceased_person = create(:deceased_person)
      create(:relation, contact_person: contact, deceased_person: deceased_person)

      expect(deceased_person.contact_name).to eq("John Doe")
    end
  end

  describe "#contact_names" do
    it "returns comma-separated contact names" do
      contact1 = create(:contact_person, first_name: "John", last_name: "Doe")
      contact2 = create(:contact_person, first_name: "Jane", last_name: "Smith")
      deceased_person = create(:deceased_person)
      create(:relation, contact_person: contact1, deceased_person: deceased_person)
      create(:relation, contact_person: contact2, deceased_person: deceased_person)

      expect(deceased_person.contact_names).to eq("John Doe,Jane Smith")
    end
  end
end
