# frozen_string_literal: true

# Hke::MessageProcessor
# Orchestrates sending a future message, handling fallback logic,
# and persisting the result in Hke::SentMessage.
module Hke
  class MessageProcessor
    include Hke::TwilioSend
    include Hke::Loggable

    def initialize(future_message)
      puts "@@@@@ in initialize"
      @future_message = future_message
    end

    # Main entry point: sends the message, records the result, and deletes the future message.
    def call
      message_sids = send_message(
        methods: delivery_methods,
        future_message: @future_message
      )

      Hke::SentMessage.create!(
        copy_attributes.merge(
          twilio_message_sid: message_sids.values.first,
          delivery_method: Hke::FutureMessage.delivery_methods[final_delivery_method]
        )
      )

      @future_message.destroy!
    end

    private

    # Determine delivery methods based on cached relation preference.
    def delivery_methods
      [@future_message.messageable.delivery_method_name]
    end

    # Determine the final delivery method, accounting for possible fallback.
    def final_delivery_method
      @fallback_used || @future_message.messageable.delivery_method_name
    end

    # Copy relevant attributes from the future message to the sent message.
    def copy_attributes
      @future_message.attributes.slice(
        "messageable_type",
        "messageable_id",
        "send_date",
        "full_message",
        "message_type",
        "metadata",
        "delivery_method",
        "email",
        "phone",
        "token",
        "deceased_first_name",
        "deceased_last_name",
        "contact_first_name",
        "contact_last_name",
        "hebrew_year_of_death",
        "hebrew_month_of_death",
        "hebrew_day_of_death",
        "relation_of_deceased_to_contact",
        "date_of_death",
        "community_id"
      )
    end
  end
end
