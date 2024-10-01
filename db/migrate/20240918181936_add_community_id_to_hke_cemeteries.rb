class AddCommunityIdToHkeCemeteries < ActiveRecord::Migration[7.1]
  def change
    add_column :hke_cemeteries, :community_id, :integer, null: false
    add_foreign_key :hke_cemeteries, :hke_communities, column: :community_id
    add_index :hke_cemeteries, :community_id
  end
end
