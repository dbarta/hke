class AddCommunityIdToHkeDeceasedPeople < ActiveRecord::Migration[7.1]
  def change
    add_column :hke_deceased_people, :community_id, :integer, null: false
    add_foreign_key :hke_deceased_people, :hke_communities, column: :community_id
    add_index :hke_deceased_people, :community_id
  end
end
