class AddApprovalToFutureMessages < ActiveRecord::Migration[7.1]
  def change
    add_column :hke_future_messages, :approval_status, :integer, default: 0
    add_column :hke_future_messages, :approved_at, :datetime
    add_reference :hke_future_messages, :approved_by, null: true, foreign_key: { to_table: :users }

    add_index :hke_future_messages, :approval_status
  end
end
