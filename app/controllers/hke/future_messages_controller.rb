module Hke
  class FutureMessagesController < ApplicationController
    # before_action :authenticate_user!
    before_action :set_community_as_current_tenant
    before_action :authenticate_admin
    before_action :set_future_message, only: [:show, :destroy, :blast]

    # GET /future_messages index
    # POST /future_messages search
    def index
  @future_messages = FutureMessage.order(:send_date)
      if params[:name_search]
        key = "%#{params[:name_search]}%"
        @future_messages = @future_messages.where("first_name ILIKE ?", key)
          .or(@future_messages.where("last_name ILIKE ?", key))
      end
      @future_messages = @future_messages.sort_by_params(params[:sort], sort_direction)
      @future_messages.load

      respond_to do |format|
        format.html # Response for normal get - show full index
        format.turbo_stream do # Response from post, which is result of input from the search box
          render turbo_stream: [
            turbo_stream.update("search_results", partial: "search_results", locals: {items: @future_messages}),
            turbo_stream.update("people_count", @future_messages.count)
          ]
        end
      end
    end

    # POST /api/v1/future_messages/123/blast
    def blast
      if @future_message.blast
        respond_to do |format|
          format.html { redirect_to future_messages_url, notice: "Future Message was successfully sent." }
         # format.json { status: :ok, location: @future_message }
        end
        # render json: @future_message, status: :ok, location: @future_message
      else
        render json: @future_message.errors, status: :unprocessable_entity
      end
    end

    # GET /future_messages/1 or /future_messages/1.json
    def show
    end

    # DELETE /deceased_people/1 or /deceased_people/1.json
    def destroy
      @future_message.destroy
      respond_to do |format|
        format.html { redirect_to future_messages_url, notice: "Future Message was successfully destroyed." }
        format.json { head :no_content }
      end
    end

    private

    # Use callbacks to share common setup or constraints between actions.
    def set_future_message
      @future_message = FutureMessage.find(params[:id])
    end

  end
end
