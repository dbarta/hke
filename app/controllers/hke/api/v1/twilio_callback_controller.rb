class Hke::Api::V1::TwilioCallbackController < Api::BaseController
#  include Hke::Loggable

  def sms_status
    # Process Twilio params here
    Rails.logger.info "Twilio webhook received: #{params.to_unsafe_h}"
    # log_info "Twilio webhook received #{params.to_unsafe_h}"
    head :ok
  end
end
