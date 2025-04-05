require 'rails_helper'

RSpec.describe Hke::MessageProcessor, type: :service do
  let(:future_message) { create(:future_message, delivery_method: :whatsapp) }

  subject { described_class.new(future_message) }

  before do
    # Stub Twilio client globally to prevent real API calls
    allow_any_instance_of(Hke::MessageProcessor).to receive(:build_twilio_client).and_return(double('TwilioClient', messages: messages_double))
  end

  let(:messages_double) { double('Messages') }

  describe '#call' do
    context 'when WhatsApp succeeds' do
      before do
        allow(messages_double).to receive(:create).and_return(double('Message', sid: 'whatsapp-sid'))
      end

      it 'creates a sent message and deletes the future message' do
        expect { subject.call }
          .to change { Hke::SentMessage.count }.by(1)
          .and change { Hke::FutureMessage.exists?(future_message.id) }.from(true).to(false)

        sent_message = Hke::SentMessage.last
        expect(sent_message.twilio_message_sid).to eq 'whatsapp-sid'
        expect(sent_message.delivery_method).to eq 'whatsapp'
      end
    end

    context 'when WhatsApp fails with no account, SMS fallback works' do
      before do
        allow(messages_double).to receive(:create).and_wrap_original do |m, params|
          if params[:from].include?('whatsapp')
            raise Twilio::REST::RestError.new('No WhatsApp account', double(code: 63016))
          else
            double('Message', sid: 'sms-sid')
          end
        end
      end

      it 'falls back to SMS and records fallback delivery method' do
        expect { subject.call }
          .to change { Hke::SentMessage.count }.by(1)
          .and change { Hke::FutureMessage.exists?(future_message.id) }.from(true).to(false)

        sent_message = Hke::SentMessage.last
        expect(sent_message.twilio_message_sid).to eq 'sms-sid'
        expect(sent_message.delivery_method).to eq 'sms'
      end
    end

    context 'when Twilio raises an unexpected error' do
      before do
        allow(messages_double).to receive(:create).and_raise(Twilio::REST::RestError.new('Unexpected error', double(code: 12345)))
      end

      it 'raises an error and does not create a sent message or delete the future message' do
        expect { subject.call }.to raise_error(Twilio::REST::RestError)

        expect(Hke::SentMessage.count).to eq 0
        expect(Hke::FutureMessage.exists?(future_message.id)).to be true
      end
    end
  end
end
