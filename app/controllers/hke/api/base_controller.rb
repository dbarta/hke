module Hke
  module Api
    class BaseController < ::Api::BaseController
      include Hke::Authorization  # Use Hke's authorization instead of main app's

      # Enable Pundit authorization for all Hke API controllers
      after_action :verify_authorized, except: [:index]
      after_action :verify_policy_scoped, only: [:index]
      rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

      private

      def user_not_authorized
        render json: { error: "Access denied" }, status: :forbidden
      end
    end
  end
end
