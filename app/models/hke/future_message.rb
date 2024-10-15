module Hke
  class FutureMessage < CommunityRecord
    # TODO:
    # 1. delivery_method - implement as bit field, with accessor functions
    # 2. instead of send_date, use two fields: scheduled_send_date_and_time and actual_sent_date_and_time
    # 3. Include also the yarzheit date, in case the message was not sent for some reason it could still be sent.

    belongs_to :messageable, polymorphic: true
    has_secure_token :token

    # Enum for delivery method
    enum delivery_method: {no_delivery: 0,
                           email: 1,
                           sms: 2,
                           whatsapp: 4}

    validates :send_date, presence: true
    validate :send_date_must_be_in_the_future
    validates :delivery_method, presence: true
    validates :full_message, presence: true
    validates :email, presence: true, if: -> { delivery_method == "email" }
    validates :email, format: {with: URI::MailTo::EMAIL_REGEXP}, if: -> { email.present? }
    validates :phone, presence: true, if: -> { %w[sms whatsapp phone].include?(delivery_method) }

    # Placeholder for message_type validation; clarify what message_type represents
    # validates :message_type, presence: true, inclusion: { in: [/* expected values */] }

    private

    def send_date_must_be_in_the_future
      if send_date.present? && send_date < Date.today # Time.current
        errors.add(:send_date, "must be in the future")
      end
    end
  end
end
