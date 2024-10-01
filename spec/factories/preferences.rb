FactoryBot.define do
  factory :preference, class: "Hke::Preference" do
    enable_send_email { true }
    enable_send_sms { false }
    enable_send_whatsapp { true }
    how_many_days_before_yahrzeit_to_send_message { [5, 7] }
    attempt_to_resend_if_no_sent_on_time { true }

    # association :preferring, factory: :relation # or the actual polymorphic association
  end

  factory :system_preference, class: "Hke::Preference" do
    enable_send_email { false }
    enable_send_sms { true }
    enable_send_whatsapp { false }
    how_many_days_before_yahrzeit_to_send_message { [7] }
    attempt_to_resend_if_no_sent_on_time { true }
  end

  factory :community_preference, class: "Hke::Preference" do
    enable_send_email { true }
    enable_send_sms { false }
    enable_send_whatsapp { false }
    how_many_days_before_yahrzeit_to_send_message { [6] }
    attempt_to_resend_if_no_sent_on_time { true }
    # association :preferring, factory: :community
  end
end
