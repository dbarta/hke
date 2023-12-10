module Hke
  class Cemetery < ApplicationRecord
    has_one :address, as: :addressable, class_name: 'Hke::Address'

    def self.polymorphic_name
      'Hke::Cemetery'
    end
  end
end
