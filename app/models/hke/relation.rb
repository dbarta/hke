module Hke
  class Relation < ApplicationRecord
    belongs_to :deceased_person
    belongs_to :contact_person
    has_many :future_messages, as: :messageable, dependent: :destroy
    has_many :relations_selections
    has_many :selections, through: :relations_selections
    has_one :preference, as: :preferring, dependent: :destroy
    has_secure_token length: 24
    accepts_nested_attributes_for :contact_person, reject_if: :all_blank
    accepts_nested_attributes_for :deceased_person, reject_if: :all_blank
    after_commit :process_future_messages

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

    private

    def process_future_messages
      future_messages.destroy_all
      create_future_messages
    end

    def create_future_messages
      yahrzeit_date = calculate_yahrzeit_date(deceased_person.date_of_passing)
      reminder_date = yahrzeit_date - 1.week

      FutureMessage.create!(
        relation: self,
        send_at: reminder_date,
        message: "Reminder: Yahrzeit for #{deceased_person.name}",
        delivery_method: contact_person.preferred_delivery_method,
        email: contact_person.email,
        phone: contact_person.phone
      )
    end

    def calculate_yahrzeit_date(date_of_passing)
      # Logic to calculate the yahrzeit date from the date of passing
    end
  end
end
