module Hke
  module Admin
    class DashboardController < ApplicationController
      before_action :authenticate_user!
      before_action :ensure_system_admin

      # Skip Pundit callbacks for dashboard since it doesn't use policies
      skip_after_action :verify_authorized
      skip_after_action :verify_policy_scoped

      def show
        @total_communities = Hke::Community.count
        @total_users = User.count
        @total_community_admins = User.community_admin.count
        @recent_communities = Hke::Community.order(created_at: :desc).limit(5)
        @recent_users = User.order(created_at: :desc).limit(5)

        # System-wide statistics
        @stats = {
          total_messages_sent: Hke::SentMessage.count,
          total_deceased_people: Hke::DeceasedPerson.count,
          total_contact_people: Hke::ContactPerson.count,
          active_communities: Hke::Community.count
        }
      end

      private

      def ensure_system_admin
        unless current_user.system_admin?
          redirect_to root_path, alert: "Access denied. System admin privileges required."
        end
      end
    end
  end
end
