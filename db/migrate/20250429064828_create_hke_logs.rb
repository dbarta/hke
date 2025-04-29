class CreateHkeLogs < ActiveRecord::Migration[7.1]
  def change
    create_table :hke_logs do |t|
      t.string   :event_type, null: false
      t.string   :entity_type
      t.bigint   :entity_id
      t.string   :message_token
      t.bigint   :user_id
      t.bigint   :community_id
      t.inet     :ip_address
      t.datetime :event_time, null: false
      t.jsonb    :details, default: {}

      t.string   :error_type
      t.text     :error_message
      t.text     :error_trace

      t.timestamps
    end

    add_index :hke_logs, [:entity_type, :entity_id]
    add_index :hke_logs, :user_id
    add_index :hke_logs, :community_id
    add_index :hke_logs, :message_token
  end
end
