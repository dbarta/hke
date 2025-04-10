require 'rails_helper'

RSpec.describe Hke::MessageProcessor, type: :service do
  let(:future_message) { create(:future_message, delivery_method: :sms, phone: ENV['TWILIO_TEST_PHONE'] || '+972584579444') }

  subject { described_class.new(future_message) }

  describe '#call' do
    it 'creates a sent message and deletes the future message' do
      expect { subject.call }
        .to change { Hke::SentMessage.count }.by(1)
        .and change { Hke::FutureMessage.exists?(future_message.id) }.from(true).to(false)

      sent_message = Hke::SentMessage.last
      expect(sent_message.twilio_message_sid).to be_present
      expect(sent_message.delivery_method).to eq 'sms'
    end
  end
end
