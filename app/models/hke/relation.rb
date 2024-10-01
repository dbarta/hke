module Hke
  class Relation < CommunityRecord
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

    def process_future_messages
      future_messages.destroy_all
      create_future_messages
    end

    def create_future_messages
      yahrzeit_date = calculate_yahrzeit_date(deceased_person.date_of_death)
      reminder_date = yahrzeit_date - 1.week

      FutureMessage.create!(
        messageable: self, # Changed relation to messageable since it is polymorphic
        send_date: reminder_date, # Changed send_at to send_date, assuming it matches the column name
        full_message: "Reminder: Yahrzeit for #{deceased_person.first_name} #{deceased_person.last_name}",
        delivery_method: calculate_delivery_method, # This will set the delivery_method enum
        email: contact_person.email,
        phone: contact_person.phone
      )
    end

    private

    def calculate_yahrzeit_date(date_of_death)
      # Here, you can implement the actual logic for calculating the Yahrzeit date
      date_of_death
    end

    def calculate_delivery_method
      # You can adjust this logic to return the correct delivery method based on preferences
      :email # This should return one of the enum symbols, e.g., :email, :sms, :whatsapp
    end
  end
end
