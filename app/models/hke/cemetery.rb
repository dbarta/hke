module Hke
  class Cemetery < CommunityRecord
    include Hke::Addressable
    validates :name, presence: {message: :presence}
  end
end
