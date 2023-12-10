class CreateHkeDeceasedPeople < ActiveRecord::Migration[7.1]
  def change
    create_table :hke_deceased_people do |t|
      t.string :first_name
      t.string :last_name
      t.string :gender
      t.string :occupation
      t.string :organization
      t.string :religion
      t.string :father_first_name
      t.string :hebrew_year_of_death
      t.string :hebrew_month_of_death
      t.string :hebrew_day_of_death
      t.string :date_of_death
      t.string :time_of_death
      t.string :location_of_death
      t.references :cemetery, null: false, foreign_key: true
      t.string :cemetery_region
      t.string :cemetery_parcel

      t.timestamps
    end
  end
end
