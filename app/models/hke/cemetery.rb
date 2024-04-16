module Hke
  class Cemetery < ApplicationRecord
    has_one :address, as: :addressable, class_name: '::Address'
    accepts_nested_attributes_for :address
    validates :name, presence: {message: :presence}

    def self.polymorphic_name
      'Hke::Cemetery'
    end
  end
end
