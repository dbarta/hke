class CreateHkeAddresses < ActiveRecord::Migration[7.1]
  def change
    create_table :hke_addresses do |t|
      t.string :name
      t.string :description
      t.string :street
      t.string :city
      t.string :region
      t.string :country
      t.string :zipcode
      t.references :addressable, polymorphic: true, null: false

      t.timestamps
    end
  end
end
