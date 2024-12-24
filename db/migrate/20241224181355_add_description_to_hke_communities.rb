class AddDescriptionToHkeCommunities < ActiveRecord::Migration[7.1]
  def change
    add_column :hke_communities, :description, :string
  end
end
