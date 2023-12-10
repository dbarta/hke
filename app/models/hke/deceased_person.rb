module Hke
  class DeceasedPerson < ApplicationRecord
    
    has_person_name
    accepts_nested_attributes_for :relations, allow_destroy: true, reject_if: :all_blank
    has_many :relations, dependent: :destroy
    has_many :contact_people, through: :relations
    belongs_to :cemetery

    before_save :calculate_gregorian_date
    before_update :calculate_gregorian_date

    def contact_name
      if self.relations.empty?
        ""
      else
        self.relations.first.contact_person.name
      end
    end
  
    def contact_names
      self.relations.map(&:contact_person.name).join(",")
    end
  
    private
  
    def calculate_gregorian_date
      self.date_of_death = Hke::h2g(self.name, self.hebrew_year_of_death, self.hebrew_month_of_death, self.hebrew_day_of_death )
    end
    
  end
end
