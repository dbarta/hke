# engines/hke/app/models/hke/concerns/reminder_processing.rb
module Hke
  module ReminderProcessing
    extend ActiveSupport::Concern

    included do
      after_commit :process_reminders
    end

    private

    def process_reminders
      FutureReminder.where(relation: relations).destroy_all

      relations.each do |relation|
        create_reminders_for_relation(relation)
      end
    end

    def create_reminders_for_relation(relation)
      yahrzeit_date = calculate_yahrzeit_date(date_of_passing)
      reminder_date = yahrzeit_date - 7.days

      FutureReminder.create!(
        relation: relation,
        send_date: reminder_date,
        unique_token: SecureRandom.uuid
      )

      log_reminder_creation(relation)
    end

    def calculate_yahrzeit_date(jewish_date)
      # Call Hebcal API to convert Jewish date to Gregorian date
      # Implement the API call and conversion logic
    end

    def log_reminder_creation(relation)
      ReminderLog.create!(
        relation: relation,
        action: "created reminder",
        timestamp: Time.current
      )
    end
  end
end
