class Hke::Api::V1::FutureMessagesController < Api::BaseController
  include Hke::SetCommunityAsTenant
  before_action :set_future_message, only: %i[show update destroy]

  # GET /future_messages
  def index
    @future_messages = Hke::FutureMessage.all
    render json: @future_messages, include: include_all?
  end

  # GET /future_messages/1
  def show
    render json: @future_message, include: include_all?
  end

  def create
    @future_message = Hke::FutureMessage.new(future_message_params)
    if @future_message.save
      render json: @future_message, status: :created, location: @future_message
    else
      render json: @future_message.errors, status: :unprocessable_entity
    end
  end

  def update
    params = future_message_params
    if @future_message.update(params)
      render json: @future_message, status: :ok
    else
      render json: @future_message.errors, status: :unprocessable_entity
    end
  end

  # DELETE /future_messages/1
  def destroy
    @future_message.destroy!
  end

  private

  def include_all?
    params.include?(:include_all) ? {address: nil} : nil
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_future_message
    @future_message = Hke::FutureMessage.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def future_message_params
    params.require(:future_message).permit(:send_date, :full_message, :message_type, :delivery_method, :email, :phone, :messageable_type, :messageable_id)
  end
end
