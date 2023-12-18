class CreateHkeLandingPages < ActiveRecord::Migration[7.1]
  def change
    create_table :hke_landing_pages do |t|
      t.string :name
      t.text :body
      t.references :user, null: false, foreign_key: { to_table: :users }
      t.timestamps
    end
  end
end
