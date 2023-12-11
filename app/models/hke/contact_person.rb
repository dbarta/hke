module Hke
  class ContactPerson < ApplicationRecord
    has_person_name
    has_many :relations, dependent: :destroy
    has_many :deceased_people, through: :relations
    has_one :address, as: :addressable, class_name: 'Hke::Address'

    accepts_nested_attributes_for :relations, allow_destroy: true, reject_if: :all_blank

    def self.polymorphic_name
      'Hke::ContactPerson'
    end
    
  end
end
