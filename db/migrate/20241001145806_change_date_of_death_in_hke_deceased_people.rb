class ChangeDateOfDeathInHkeDeceasedPeople < ActiveRecord::Migration[7.1]
  def change
    remove_column :hke_deceased_people, :date_of_death, :string
    remove_column :hke_deceased_people, :time_of_death, :string

    # Add a new datetime column called date_of_death
    add_column :hke_deceased_people, :date_of_death, :datetime
    add_column :hke_deceased_people, :time_of_death, :time
  end
end
