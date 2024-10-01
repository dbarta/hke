class RemovecolumncommunityIdfromhkePreferences < ActiveRecord::Migration[7.1]
  def change
    remove_column :hke_preferences, :community_id, :bigint
  end
end
