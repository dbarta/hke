class CreateHkeCsvImportLogsAndAddNameToImports < ActiveRecord::Migration[7.1]
  def change
    create_table :hke_csv_import_logs do |t|
      t.references :csv_import, null: false, foreign_key: { to_table: :hke_csv_imports }
      t.string :level, null: false
      t.integer :row_number
      t.text :message, null: false
      t.jsonb :details

      t.timestamps
    end

    add_index :hke_csv_import_logs, [:csv_import_id, :row_number]
    add_index :hke_csv_import_logs, :level

    add_column :hke_csv_imports, :name, :string
  end
end

