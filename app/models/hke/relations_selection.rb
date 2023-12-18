module Hke
  class RelationsSelection < ApplicationRecord
    belongs_to :relation
    belongs_to :selection
  end
end
