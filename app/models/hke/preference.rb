module Hke
  class Preference < ApplicationRecord
    belongs_to :preferring, polymorphic: true

    # Attributes
    # t.boolean :enable_send_email, default: true
    # t.boolean :enable_send_sms, default: false
    # t.boolean :enable_send_whatsapp, default: false
    # t.integer :how_many_days_before_yahrzeit_to_send_message, array: true, default: [7]
    # t.boolean :attempt_to_resend_if_no_sent_on_time, default: true

    validates :how_many_days_before_yahrzeit_to_send_message, presence: true
  end
end
