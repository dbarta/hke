class AddRolesAndCommunityToUsers < ActiveRecord::Migration[7.1]
  def change
    # Add roles column for Rolified (required for the new role system)
    add_column :users, :roles, :jsonb, default: {}, null: false

    # Add optional community assignment for community-scoped users
    add_column :users, :community_id, :bigint, null: true

    # Add foreign key constraint to hke_communities
    add_foreign_key :users, :hke_communities, column: :community_id

    # Add indexes for performance
    add_index :users, :community_id
    add_index :users, :roles, using: :gin
  end
end