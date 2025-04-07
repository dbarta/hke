class AddCommunityIdToHkeSentMessages < ActiveRecord::Migration[7.1]
  def change
    add_column :hke_sent_messages, :community_id, :integer, null: false
    add_foreign_key :hke_sent_messages, :hke_communities, column: :community_id
    add_index :hke_sent_messages, :community_id
  end
end
