class CreateHkeSelections < ActiveRecord::Migration[7.1]
  def change
    create_table :hke_selections do |t|
      t.string :name
      t.string :description

      t.timestamps
    end
  end
end
