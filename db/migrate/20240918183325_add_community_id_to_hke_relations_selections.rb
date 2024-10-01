class AddCommunityIdToHkeRelationsSelections < ActiveRecord::Migration[7.1]
  def change
    add_column :hke_relations_selections, :community_id, :integer, null: false
    add_foreign_key :hke_relations_selections, :hke_communities, column: :community_id
    add_index :hke_relations_selections, :community_id
  end
end
