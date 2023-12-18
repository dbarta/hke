module Hke
  class Selection < ApplicationRecord
    has_many :relations_selections
    has_many :relations, through: :relations_selections
  end
end
