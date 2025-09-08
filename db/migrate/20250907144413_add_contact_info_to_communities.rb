class AddContactInfoToCommunities < ActiveRecord::Migration[7.1]
  def change
    add_column :hke_communities, :phone_number, :string
    add_column :hke_communities, :email_address, :string
  end
end
