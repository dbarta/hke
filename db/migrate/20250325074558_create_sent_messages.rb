class CreateHkeSentMessages < ActiveRecord::Migration[7.1]
  def change
    create_table :hke_sent_messages do |t|
      t.references :messageable, polymorphic: true, null: false
      t.datetime :send_date
      t.text :full_message
      t.integer :message_type
      t.json :metadata
      t.integer :delivery_method
      t.string :email
      t.string :phone
      t.string :token
      t.string :twilio_message_sid
      t.string :deceased_first_name
      t.string :deceased_last_name
      t.string :contact_first_name
      t.string :contact_last_name
      t.string :hebrew_year_of_death
      t.string :hebrew_month_of_death
      t.string :hebrew_day_of_death
      t.string :relation_of_deceased_to_contact
      t.date :date_of_death

      t.timestamps
    end
    add_index :hke_sent_messages, :token, unique: true
    add_index :hke_sent_messages, :twilio_message_sid, unique: true
  end
end
