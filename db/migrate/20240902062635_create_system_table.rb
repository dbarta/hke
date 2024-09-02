class CreateSystemTable < ActiveRecord::Migration[7.1]
  def change
    create_table :hke_system_tables do |t|
      t.string :product_name, default: "Hakhel"
      t.string :version, default: "1.0"

      t.timestamps
    end
  end
end
