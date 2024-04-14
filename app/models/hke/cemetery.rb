module Hke
  class Cemetery < ApplicationRecord
    has_one :address, as: :addressable, class_name: 'Hke::Address'
    validates :name, presence: {message: :presence}

    def self.polymorphic_name
      'Hke::Cemetery'
    end
  end
end
