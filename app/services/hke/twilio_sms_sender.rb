require 'twilio-ruby'

module Hke
  class TwilioSmsSender
    def self.send_sms(to:, message:)
      client = Twilio::REST::Client.new(
        Rails.application.credentials.dig(:twilio, :account_sid),
        Rails.application.credentials.dig(:twilio, :auth_token)
      )

      client.messages.create(
        from: Rails.application.credentials.dig(:twilio, :phone_number),
        to: to,
        body: message
      )
    end
  end
end