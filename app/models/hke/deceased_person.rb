require_relative '../../../lib/hke/heb'
module Hke
  class DeceasedPerson < ApplicationRecord

    # Associations
    has_many :relations, dependent: :destroy
    has_many :contact_people, through: :relations
    belongs_to :cemetery

    # Validations
    validates :first_name, :last_name, :gender, presence: true
    validates :hebrew_year_of_death, :hebrew_month_of_death, :hebrew_day_of_death, presence: true

    # Transformations
    include Hke::HebrewTransformations
    after_validation :transform_gender, :transform_hebrew_dates
   
    has_person_name
    accepts_nested_attributes_for :relations, allow_destroy: true, reject_if: :all_blank

    def contact_name
      if relations.empty?
        ""
      else
        relations.first.contact_person.name
      end
    end
  
    def contact_names
      relations.map { |relation| relation.contact_person.name }.join(",")
    end
  
  end
end
