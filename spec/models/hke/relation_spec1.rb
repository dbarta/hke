require "rails_helper"

RSpec.describe Hke::Relation, type: :model do
  it { should belong_to(:deceased_person) }
  it { should belong_to(:contact_person) }
  it { should have_many(:future_messages).dependent(:destroy) }

  it { should accept_nested_attributes_for(:contact_person).reject_if(:all_blank) }
  it { should accept_nested_attributes_for(:deceased_person).reject_if(:all_blank) }

  describe "#contact_person_attributes=" do
    it "finds or initializes a contact_person by phone" do
      contact = create(:contact_person, phone: "123456789")
      relation = Hke::Relation.new(contact_person_attributes: {phone: "123456789", first_name: "New", last_name: "Person"})
      expect(relation.contact_person).to eq(contact)
      expect(relation.contact_person.first_name).to eq("New")
      expect(relation.contact_person.last_name).to eq("Person")
    end
  end

  describe "#deceased_person_attributes=" do
    it "finds or initializes a deceased_person by first and last name" do
      deceased_person = create(:deceased_person, first_name: "Jane", last_name: "Doe")
      relation = Hke::Relation.new(deceased_person_attributes: {first_name: "Jane", last_name: "Doe", gender: "female"})
      expect(relation.deceased_person).to eq(deceased_person)
      expect(relation.deceased_person.gender).to eq("female")
    end
  end
end
