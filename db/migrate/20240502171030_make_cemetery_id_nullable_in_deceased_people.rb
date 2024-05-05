class MakeCemeteryIdNullableInDeceasedPeople < ActiveRecord::Migration[7.1]
  def change
    change_column_null :hke_deceased_people, :cemetery_id, true
  end
end


