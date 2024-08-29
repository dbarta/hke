module Hke
  class Relation < ApplicationRecord
    belongs_to :deceased_person
    belongs_to :contact_person
    has_many :future_messages, as: :messageable, dependent: :destroy
    has_many :relations_selections
    has_many :selections, through: :relations_selections
    has_secure_token length: 24
    accepts_nested_attributes_for :contact_person, reject_if: :all_blank
    accepts_nested_attributes_for :deceased_person, reject_if: :all_blank

    # Setter method for contact_person nested attributes
    def contact_person_attributes=(attributes)
      if attributes["phone"].present?
        self.contact_person = ContactPerson.find_or_initialize_by(phone: attributes["phone"])
        contact_person.assign_attributes(attributes)
      end
    end

    # Setter method for deceased_person nested attributes
    def deceased_person_attributes=(attributes)
      if attributes["first_name"].present? && attributes["last_name"].present?
        self.deceased_person = DeceasedPerson.find_or_initialize_by(
          first_name: attributes["first_name"],
          last_name: attributes["last_name"]
        )
        deceased_person.assign_attributes(attributes)
      end
    end
  end
end
