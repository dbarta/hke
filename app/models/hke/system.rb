module Hke
  class System < ApplicationRecord
    include Hke::SystemInfoConcern
    has_one :preference, as: :preferring, class_name: "Hke::Preference", dependent: :destroy

    # Singleton pattern to ensure only one instance of System
    def self.instance
      i = first_or_create
      puts "@@@@ after first_or_create, preference: #{i.preference}"
      i
    end

    def preference
      puts "@@@@ Preference accessed"
      super
    end
  end
end
