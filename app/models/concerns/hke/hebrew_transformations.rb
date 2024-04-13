module Hke
    module HebrewTransformations
    extend ActiveSupport::Concern
    include Hke::ApplicationHelper
  
    # included do
    #   after_validation :shared_custom_method
    # end

    def transform_gender
        gender = english_gender(self.gender)
        if gender == nil 
            errors.add(:gender, :gender_invalid)
        else
            self.gender = english_gender(self.gender)  # self refers to the model instance (record)
        end
    end

    def transform_hebrew_dates
        check_and_transform_hebrew_month
        check_and_transform_hebrew_day
        calculate_gregorian_date_of_death
    end

    def check_and_transform_hebrew_month
        english_month = hebrew_month_to_english(hebrew_month_of_death)
        if english_month
          hebrew_month_of_death = english_month_to_hebrew(english_month)
        else
          errors.add(:hebrew_month_of_death, :value_invalid)
        end
    end

    def check_and_transform_hebrew_day
        num = hebrew_date_numeric_value(hebrew_day_of_death)
        if (1..31).include? num
            hebrew_day_of_death = hebrew_day_select[num-1] # Array begins with 0
        else
            errors.add(:hebrew_day_of_death, :value_invalid)
        end        
    end

    def calculate_gregorian_date_of_death
        date_of_death = Hke::h2g name, hebrew_year_of_death, hebrew_month_of_death, hebrew_day_of_death
    end
  
    def english_gender hebrew_gender
        # [ [ "זכר" , "male" ],  [ "נקבה" , "female" ] ]
        he_en_pair = gender_select.find{|pair| pair[0]==hebrew_gender}
        he_en_pair ? he_en_pair[1] : nil
    end
  end
end