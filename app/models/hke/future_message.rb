module Hke
  class FutureMessage < ApplicationRecord
    belongs_to :messageable, polymorphic: true

    # Generate a unique token using the has_token gem
    has_token :token

    # Enum for delivery method
    enum delivery_method: {email: 0, phone: 1, both: 2}

    # Validations
    # validates :send_date, presence: true, timeliness: {on_or_after: -> { Time.current }, type: :datetime}
    validates :delivery_method, presence: true
    validates :full_message, presence: true
    validates :email, format: {with: URI::MailTo::EMAIL_REGEXP}, if: -> { email.present? }
    validates :phone, phone: true, if: -> { phone.present? }

    # Placeholder for message_type validation; clarify what message_type represents
    # validates :message_type, presence: true, inclusion: { in: [/* expected values */] }
  end
end
