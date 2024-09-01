class CreatePreferences < ActiveRecord::Migration[7.1]
  def change
    create_table :hke_preferences do |t|
      t.references :preferring, polymorphic: true, null: false
      t.boolean :enable_send_email, default: true
      t.boolean :enable_send_sms, default: true
      t.boolean :enable_send_whatsapp, default: true
      t.integer :how_many_days_before_yahrzeit_to_send_message, array: true, default: [7]
      t.boolean :attempt_to_resend_if_no_sent_on_time

      t.timestamps
    end
  end
end
