class AddCommunityIdToHkeLandingPages < ActiveRecord::Migration[7.1]
  def change
    add_column :hke_landing_pages, :community_id, :integer, null: false
    add_foreign_key :hke_landing_pages, :hke_communities, column: :community_id
    add_index :hke_landing_pages, :community_id
  end
end
