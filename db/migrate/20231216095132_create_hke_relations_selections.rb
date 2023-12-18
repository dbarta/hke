class CreateHkeRelationsSelections < ActiveRecord::Migration[7.1]
  def change
    create_table :hke_relations_selections do |t|
      t.references :relation, null: false, foreign_key: { to_table: :hke_relations }
      t.references :selection, null: false, foreign_key: { to_table: :hke_selections }

      t.timestamps
    end
  end
end
