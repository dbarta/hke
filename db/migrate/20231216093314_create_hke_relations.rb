class CreateHkeRelations < ActiveRecord::Migration[7.1]
  def change
    create_table :hke_relations do |t|
      t.string :relation_of_deceased_to_contact
      t.string :token
      t.references :deceased_person, null: false, foreign_key: { to_table: :hke_deceased_people }
      t.references :contact_person, null: false, foreign_key: { to_table: :hke_contact_people }
      t.timestamps
    end
  end
end
