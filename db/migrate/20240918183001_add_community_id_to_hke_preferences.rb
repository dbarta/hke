class AddCommunityIdToHkePreferences < ActiveRecord::Migration[7.1]
  def change
    add_column :hke_preferences, :community_id, :integer, null: false
    add_foreign_key :hke_preferences, :hke_communities, column: :community_id
    add_index :hke_preferences, :community_id
  end
end
