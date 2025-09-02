module Hke
  class DashboardController < ApplicationController
    include Hke::SetCommunityAsTenant

    def show
      @messages = Hke::FutureMessage.for_current_week
    end
  end
end
