module Hke
  module Admin
    class CommunitiesController < ApplicationController
      before_action :authenticate_user!
      before_action :set_community, only: [:show, :edit, :update, :destroy]

      # GET /admin/communities index
      # POST /admin/communities search
      def index
        @communities = policy_scope(Hke::Community).includes(:account)
        if params[:name_search]
          key = "%#{params[:name_search]}%"
          @communities = @communities.where("name ILIKE ?", key)
        end
        @communities = @communities.order(:name)
        @communities.load

        respond_to do |format|
          format.html # Response for normal get - show full index
          format.turbo_stream do # Response from post, which is result of input from the search box
            render turbo_stream: [
              turbo_stream.update("search_results", partial: "hke/shared/search_results", locals: {items: @communities}),
              turbo_stream.update("communities_count", @communities.count)
            ]
          end
        end
      end

      def show
        authorize @community
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
        authorize @community
        @community.build_account
      end

      def create
        @community = Hke::Community.new(community_params)
        authorize @community

        if @community.save
          redirect_to admin_community_path(@community), notice: 'Community was successfully created.'
        else
          render :new
        end
      end

      def edit
        authorize @community
      end

      def update
        authorize @community
        if @community.update(community_params)
          redirect_to admin_community_path(@community), notice: 'Community was successfully updated.'
        else
          render :edit
        end
      end

      def destroy
        authorize @community
        @community.destroy
        redirect_to admin_communities_path, notice: 'Community was successfully deleted.'
      end

      private

      def set_community
        @community = Hke::Community.find(params[:id])
      end

      def community_params
        params.require(:community).permit(:name, :community_type, :account_id)
      end
    end
  end
end
