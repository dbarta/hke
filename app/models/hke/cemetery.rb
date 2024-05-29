module Hke
  class Cemetery < ApplicationRecord
    include Hke::Addressable
    validates :name, presence: {message: :presence}
  end
end
