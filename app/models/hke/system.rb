module Hke
  class System < ApplicationRecord
    include Hke::SystemInfoConcern
    include Hke::Preferring

    # Singleton pattern to ensure only one instance of System
    def self.instance
      first_or_create
    end

    def preference
      super
    end
  end
end
