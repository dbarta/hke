class CreateHkeFutureMessages < ActiveRecord::Migration[7.1]
  def change
    create_table :hke_future_messages do |t|
      t.references :messageable, polymorphic: true, null: false
      t.datetime :send_date
      t.text :full_message
      t.integer :message_type
      t.json :metadata
      t.integer :delivery_method
      t.string :email
      t.string :phone
      t.string :token

      t.timestamps
    end
    add_index :hke_future_messages, :token, unique: true
  end
end
