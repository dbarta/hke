module Hke
  module Admin
    class UsersController < ApplicationController
      before_action :authenticate_user!
      before_action :ensure_system_admin
      before_action :set_user, only: [:show, :edit, :update, :destroy]

      # Skip Pundit callbacks for admin controllers
      skip_after_action :verify_authorized
      skip_after_action :verify_policy_scoped

      def index
        @users = User.includes(:community).order(:email)
        @system_admins = @users.select(&:system_admin?)
        @community_admins = @users.select(&:community_admin?)
        @community_users = @users.select(&:community_user?)
      end

      def show
        @user_accounts = @user.accounts
        @user_communities = @user.community ? [@user.community] : []
      end

      def new
        @user = User.new
        @communities = Hke::Community.all
      end

      def create
        @user = User.new(user_params)
        @communities = Hke::Community.all

        if @user.save
          redirect_to admin_user_path(@user), notice: 'User was successfully created.'
        else
          render :new
        end
      end

      def edit
        @communities = Hke::Community.all
      end

      def update
        if @user.update(user_params)
          redirect_to admin_user_path(@user), notice: 'User was successfully updated.'
        else
          @communities = Hke::Community.all
          render :edit
        end
      end

      def destroy
        if @user == current_user
          redirect_to admin_users_path, alert: 'Cannot delete your own account.'
          return
        end

        @user.destroy
        redirect_to admin_users_path, notice: 'User was successfully deleted.'
      end

      private

      def set_user
        @user = User.find(params[:id])
      end

      def user_params
        params.require(:user).permit(:first_name, :last_name, :email, :password, :password_confirmation,
                                     :community_id, :terms_of_service, roles: {})
      end

      def ensure_system_admin
        unless current_user.system_admin?
          redirect_to root_path, alert: "Access denied. System admin privileges required."
        end
      end
    end
  end
end
