module Hke::HebrewTransformations
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
  
    def english_gender hebrew_gender
        # [ [ "זכר" , "male" ],  [ "נקבה" , "female" ] ]
        he_en_pair = gender_select.find{|pair| pair[0]==hebrew_gender}
        he_en_pair ? he_en_pair[1] : nil
    end
  end