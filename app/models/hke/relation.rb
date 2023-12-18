module Hke
  class Relation < ApplicationRecord
    belongs_to :deceased_person
    belongs_to :contact_person
    has_many :relations_selections
    has_many :selections, through: :relations_selections
    has_secure_token length: 24
    accepts_nested_attributes_for :contact_person, reject_if: :all_blank
    accepts_nested_attributes_for :deceased_person, reject_if: :all_blank
  end
end
