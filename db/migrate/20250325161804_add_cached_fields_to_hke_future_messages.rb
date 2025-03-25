class AddCachedFieldsToHkeFutureMessages < ActiveRecord::Migration[7.1]
  def change
    change_table :hke_future_messages do |t|
      t.string :deceased_first_name
      t.string :deceased_last_name
      t.string :contact_first_name
      t.string :contact_last_name
      t.string :hebrew_year_of_death
      t.string :hebrew_month_of_death
      t.string :hebrew_day_of_death
      t.string :relation_of_deceased_to_contact
      t.date :date_of_death
    end
  end
end
