class CreateHkeCommunities < ActiveRecord::Migration[6.1]
  def change
    create_table :hke_communities do |t|
      t.string :name, null: false
      t.string :community_type, null: false # Enum as string
      t.references :account, null: false, foreign_key: true

      t.timestamps
    end
  end
end
