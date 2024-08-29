require "rails_helper"

module Hke
  RSpec.describe FutureMessage, type: :model do
    it { should belong_to(:messageable) }

    it { should validate_presence_of(:send_date) }
    it { should validate_presence_of(:delivery_method) }
    it { should validate_presence_of(:full_message) }

    it do
      should define_enum_for(:delivery_method)
        .with_values(email: 0, phone: 1, both: 2)
    end

    describe "send_date validation" do
      it "is invalid if send_date is in the past" do
        future_message = build(:future_message, send_date: 1.day.ago)
        expect(future_message.valid?).to be_falsey
        expect(future_message.errors[:send_date]).to include("must be in the future")
      end

      it "is valid if send_date is in the future" do
        future_message = build(:future_message, send_date: 1.day.from_now)
        expect(future_message.valid?).to be_truthy
      end
    end

    describe "email validation" do
      it "is invalid if email is not in the correct format" do
        future_message = build(:future_message, email: "invalid_email")
        expect(future_message.valid?).to be_falsey
        expect(future_message.errors[:email]).to include("is invalid")
      end

      it "is valid if email is in the correct format" do
        future_message = build(:future_message, email: "valid@example.com")
        expect(future_message.valid?).to be_truthy
      end

      it "creates a valid FutureMessage record and reads it from the database" do
        # Set up a valid messageable object
        messageable = create(:some_model) # Assuming you have a factory for some_model

        # Create a valid FutureMessage record
        original_message = Hke::FutureMessage.create!(
          send_date: Time.current + 1.day,
          messageable: messageable,
          full_message: "This is a test message",
          delivery_method: :email,
          email: "test@example.com",
          phone: "+1234567890"
        )

        # Reload the record from the database
        retrieved_message = Hke::FutureMessage.find(original_message.id)

        # Check if the retrieved fields match the original values
        expect(retrieved_message.send_date.to_i).to eq(original_message.send_date.to_i)
        expect(retrieved_message.messageable).to eq(original_message.messageable)
        expect(retrieved_message.full_message).to eq(original_message.full_message)
        expect(retrieved_message.delivery_method).to eq(original_message.delivery_method)
        expect(retrieved_message.email).to eq(original_message.email)
        expect(retrieved_message.phone).to eq(original_message.phone)
      end
    end
  end

  RSpec.describe Hke::FutureMessage, type: :model do
  end
end
