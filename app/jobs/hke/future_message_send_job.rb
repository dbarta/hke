module Hke
  class FutureMessageSendJob
    include Sidekiq::Job
    include Hke::JobLoggingHelper

    def perform(future_message_id)
      future_message = Hke::FutureMessage.find_by(id: future_message_id)
      unless future_message
        log_error("Create Job", details: "future message #{future_message_id} not found")
        return
      end

      begin
        log_event("Create Job", details: { text: "Creating send job for message: #{future_message_id}"})
        Hke::MessageProcessor.new(future_message).call

        log_event "Create Job", details: {text:"Send job created for message: #{future_message.id}"}
      rescue => e
        log_error "Create Job", error: e
        raise e
      end
    end
  end
end
