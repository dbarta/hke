FactoryBot.define do
  factory :future_message, class: "Hke::futureMesssage" do
    messageable { create(:relation) } # assuming you have this, or you can stub
    send_date { Time.current }
    full_message { 'Test message body' }
    message_type { 0 } # or enum name if defined
    delivery_method { :whatsapp } # assuming enum
    email { 'test@example.com' }
    phone { '+1234567890' }
    token { SecureRandom.hex(10) }
    community_id { 1 } # or dynamically create if your setup requires
    deceased_first_name { 'John' }
    deceased_last_name { 'Doe' }
    contact_first_name { 'Jane' }
    contact_last_name { 'Smith' }
    hebrew_year_of_death { '5784' }
    hebrew_month_of_death { 'Nissan' }
    hebrew_day_of_death { '15' }
    relation_of_deceased_to_contact { 'אב' }
    date_of_death { Date.current - 1.year }
    metadata { {} }
  end
end
