class CreateHkeCsvImports < ActiveRecord::Migration[7.1]
  def change
    create_table :hke_csv_imports do |t|
      t.integer :status, default: 0
      t.integer :import_type, default: 0
      t.integer :total_rows, default: 0
      t.integer :processed_rows, default: 0
      t.integer :successful_rows, default: 0
      t.integer :failed_rows, default: 0
      t.text :errors_data
      t.references :user, null: false, foreign_key: { to_table: :users }
      t.references :community, null: false, foreign_key: { to_table: :hke_communities }

      t.timestamps
    end

    add_index :hke_csv_imports, :status
    add_index :hke_csv_imports, :import_type
  end
end
