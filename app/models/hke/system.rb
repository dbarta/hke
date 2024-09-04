module Hke
  class System < ApplicationRecord
    include Hke::SystemInfoConcern
    has_one :preference, as: :preferring, class_name: "Hke::Preference", dependent: :destroy

    # Singleton pattern to ensure only one instance of System
    def self.instance
      i = first_or_create
      p = i.preference
      puts "@@@@ after first_or_create, preference: #{p} attributes:#{p.attributes}"
      i
    end

    def preference
      puts "@@@@ Preference accessed"
      super
    end
  end
end
