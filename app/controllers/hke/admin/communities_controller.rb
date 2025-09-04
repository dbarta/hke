module Hke
  module Admin
    class CommunitiesController < ApplicationController
      before_action :authenticate_user!
      before_action :ensure_system_admin
      before_action :set_community, only: [:show, :edit, :update, :destroy]

      # Skip Pundit callbacks for admin controllers
      skip_after_action :verify_authorized
      skip_after_action :verify_policy_scoped

      def index
        @communities = Hke::Community.includes(:account).order(:name)
      end

      def show
        @community_admins = User.where(community: @community).community_admin
        @community_users = User.where(community: @community).community_user
        @stats = {
          total_users: User.where(community: @community).count,
          total_admins: @community_admins.count,
          created_at: @community.created_at
        }
      end

      def new
        @community = Hke::Community.new
        @community.build_account
      end

      def create
        @community = Hke::Community.new(community_params)

        if @community.save
          redirect_to admin_community_path(@community), notice: 'Community was successfully created.'
        else
          render :new
        end
      end

      def edit
      end

      def update
        if @community.update(community_params)
          redirect_to admin_community_path(@community), notice: 'Community was successfully updated.'
        else
          render :edit
        end
      end

      def destroy
        @community.destroy
        redirect_to admin_communities_path, notice: 'Community was successfully deleted.'
      end

      private

      def set_community
        @community = Hke::Community.find(params[:id])
      end

      def community_params
        params.require(:community).permit(:name, :community_type, :description,
          account_attributes: [:id, :name, :billing_email])
      end

      def ensure_system_admin
        unless current_user.system_admin?
          redirect_to root_path, alert: "Access denied. System admin privileges required."
        end
      end
    end
  end
end
