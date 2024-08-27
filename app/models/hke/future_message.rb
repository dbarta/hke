module Hke
  class FutureMessage < ApplicationRecord
    belongs_to :messageable, polymorphic: true
  end
end
