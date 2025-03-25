require 'twilio-ruby'
require 'sendgrid-ruby'

module Hke
  class TwilioSend
    include Hke::Loggable
    include SendGrid

    MODALITIES = %i[sms whatsapp email].freeze

    def self.send_message(methods:, future_message:)
      new(methods, future_message).call
    end

    def initialize(methods, future_message)
      @methods = methods & MODALITIES
      @future_message = future_message
      @message_sids = {}
      @client = build_twilio_client
    end

    def call
      @methods.each do |method|
        case method
        when :sms
          @message_sids[:sms] = send_sms
        when :whatsapp
          @message_sids[:whatsapp] = send_whatsapp
        when :email
          @message_sids[:email] = send_email
        end
      end
      @message_sids
    rescue Twilio::REST::RestError, SendGrid::Error => e
      log_error "Message sending failed: #{e.message}"
      raise
    end

    private

    def build_twilio_client
      Twilio::REST::Client.new(
        ENV['TWILIO_ACCOUNT_SID'] || Rails.application.credentials.dig(:twilio, :account_sid),
        ENV['TWILIO_AUTH_TOKEN'] || Rails.application.credentials.dig(:twilio, :auth_token)
      )
    end

    def send_sms
      message = @client.messages.create(
        from: ENV['TWILIO_PHONE_NUMBER'] || Rails.application.credentials.dig(:twilio, :phone_number),
        to: @future_message.contact.phone,
        body: @future_message.message_body,
        status_callback: webhook_url(:sms)
      )
      log_info "SMS sent to #{@future_message.contact.phone}, SID: #{message.sid}"
      message.sid
    end

    def send_whatsapp
      message = @client.messages.create(
        from: 'whatsapp:+14155238886',
        to: "whatsapp:#{@future_message.contact.phone}",
        body: @future_message.message_body,
        status_callback: webhook_url(:whatsapp)
      )
      log_info "WhatsApp message sent to #{@future_message.contact.phone}, SID: #{message.sid}"
      message.sid
    end

    def send_email
      from = Email.new(email: ENV['SENDGRID_FROM_EMAIL'] || 'no-reply@yourapp.com')
      to = Email.new(email: @future_message.contact.email)
      subject = 'Message from Hakehl'
      content = Content.new(type: 'text/plain', value: @future_message.message_body)

      mail = Mail.new(from, subject, to, content)
      sg = SendGrid::API.new(api_key: ENV['SENDGRID_API_KEY'] || Rails.application.credentials.dig(:sendgrid, :api_key))
      response = sg.client.mail._('send').post(request_body: mail.to_json)

      if response.status_code.to_i.between?(200, 299)
        log_info "Email sent to #{@future_message.contact.email}, Status: #{response.status_code}"
        "email-#{SecureRandom.hex(6)}"
      else
        raise SendGrid::Error.new("Email failed with status #{response.status_code}")
      end
    end

    def webhook_url(modality)
      Rails.application.routes.url_helpers.twilio_sms_status_url(
        host: ENV['WEBHOOK_HOST'],
        modality: modality
      )
    end
  end
end
