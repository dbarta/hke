class AddCommunityIdToHkeFutureMessages < ActiveRecord::Migration[7.1]
  def change
    add_column :hke_future_messages, :community_id, :integer, null: false
    add_foreign_key :hke_future_messages, :hke_communities, column: :community_id
    add_index :hke_future_messages, :community_id
  end
end
