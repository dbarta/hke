module Hke
  class FutureMessage < ApplicationRecord
    belongs_to :messageable, polymorphic: true

    has_secure_token :token

    # Enum for delivery method
    enum delivery_method: {email: 0, phone: 1, both: 2}

    # Validations
    # validates :send_date, presence: true, timeliness: {on_or_after: -> { Time.current }, type: :datetime}
    validates :send_date, presence: true
    validate :send_date_must_be_in_the_future
    validates :delivery_method, presence: true
    validates :full_message, presence: true
    validates :email, format: {with: URI::MailTo::EMAIL_REGEXP}, if: -> { email.present? }
    # validates :phone, phone: true, if: -> { phone.present? }

    # Placeholder for message_type validation; clarify what message_type represents
    # validates :message_type, presence: true, inclusion: { in: [/* expected values */] }

    private

    def send_date_must_be_in_the_future
      if send_date.present? && send_date < Time.current
        errors.add(:send_date, "must be in the future")
      end
    end
  end
end
