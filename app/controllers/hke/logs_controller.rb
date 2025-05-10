module Hke
  class LogsController < ApplicationController
    include Hke::SetCommunityAsTenant
    helper Hke::ApplicationHelper
    include Pagy::Backend

    def index
      # @event_types = Hke::Log.distinct.pluck(:event_type).compact.sort

      # scope = Hke::Log.all

      # if params[:event_type].present?
      #   scope = scope.where(event_type: params[:event_type])
      # end

      # if params[:start].present? && params[:end].present?
      #   scope = scope.where(event_time: params[:start]..params[:end])
      # end

      # sort_column = %w[event_time event_type entity_type message_token ip_address error_type].include?(params[:sort]) ? params[:sort] : "event_time"
      # sort_direction = %w[asc desc].include?(params[:direction]) ? params[:direction] : "desc"

      # scope = scope.order("#{sort_column} #{sort_direction}")

      # scope = Hke::Log.all
      # @pagy, @logs = pagy(scope, items: 100)
      @logs = Hke::Log.all
      @logs.load
      puts "@@@@@@@@@ log count: #{@logs.count}"

      # respond_to do |format|
      #   format.html
      #   format.json { render json: @logs }
      # end
    end
  end
end
