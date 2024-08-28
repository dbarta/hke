require "rails_helper"

module Hke
  RSpec.describe FutureMessage, type: :model do
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
