module Hke
  class DashboardController < ApplicationController
    include Hke::SetCommunityAsTenant
    before_action :authenticate_user!

    # Skip Pundit callbacks for dashboard since it does role-based routing
    skip_after_action :verify_authorized
    skip_after_action :verify_policy_scoped

    def show
      # Role-based dashboard routing
      if current_user.system_admin?
        redirect_to admin_root_path
      elsif current_user.community_admin?
        show_community_admin_dashboard
      elsif current_user.community_user?
        show_community_user_dashboard
      else
        redirect_to root_path, alert: "Access denied. Please contact administrator."
      end
    end

    private

    def show_community_admin_dashboard
      @messages = Hke::FutureMessage.for_current_week
      @pending_approvals = Hke::FutureMessage.pending_approval.limit(10)
      @recent_failures = Hke::SentMessage.failed.recent.limit(5)
      @stats = {
        total_sent_this_week: Hke::SentMessage.sent_this_week.count,
        total_failures: Hke::SentMessage.failed.count,
        pending_this_week: @messages.count
      }
      render 'show_community_admin'
    end

    def show_community_user_dashboard
      # Future implementation for community users
      render 'show_community_user'
    end
  end
end
