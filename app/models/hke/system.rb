module Hke
  class System < ApplicationRecord
    include Hke::SystemInfoConcern
    has_one :preference, as: :preferring, class_name: "Hke::Preference", dependent: :destroy

    # Singleton pattern to ensure only one instance of System
    def self.instance
      first_or_create
    end
  end
end
