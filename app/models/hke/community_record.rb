module Hke
  class CommunityRecord < ApplicationRecord
    self.abstract_class = true
    acts_as_tenant :community if defined? ActsAsTenant
  end
end
