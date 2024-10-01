class AddCommunityIdToHkeContactPeople < ActiveRecord::Migration[7.1]
  def change
    add_column :hke_contact_people, :community_id, :integer, null: false
    add_foreign_key :hke_contact_people, :hke_communities, column: :community_id
    add_index :hke_contact_people, :community_id
  end
end
