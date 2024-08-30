FactoryBot.define do
  factory :future_message, class: "Hke::futureMesssage" do
    messageable { nil }
    send_date { "2024-08-27 10:51:46" }
    full_message { "MyText" }
    message_type { 1 }
    metadata { "" }
    delivery_method { 1 }
    email { "MyString" }
    phone { "MyString" }
    token { "MyString" }
  end
end
