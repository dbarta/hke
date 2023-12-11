class CreateHkeContactPeople < ActiveRecord::Migration[7.1]
  def change
    create_table :hke_contact_people do |t|
      t.string :first_name
      t.string :last_name
      t.string :email
      t.string :phone
      t.string :gender

      t.timestamps
    end
  end
end
