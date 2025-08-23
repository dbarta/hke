module Hke
  class FutureMessageSendJob
    include Sidekiq::Job
    include Hke::JobLoggingHelper

    def perform(future_message_id, community_id)
      community = Hke::Community.find_by(id: community_id)
      ActsAsTenant.current_tenant = community if community
      future_message = Hke::FutureMessage.find_by(id: future_message_id)
      unless future_message
        log_error("Create Job", details: { text: "future message #{future_message_id} not found", community_id: community_id })
        ActsAsTenant.current_tenant = nil
        return
      end

      begin
        log_event("Create Job", details: { text: "Creating send job for message: #{future_message_id}", community_id: community_id })
        Hke::MessageProcessor.new(future_message).call

        log_event "Create Job", details: {text:"Send job created for message: #{future_message.id}", community_id: community_id }
      rescue => e
        log_error "Create Job", error: e, details: { community_id: community_id }
        raise e
      ensure
        ActsAsTenant.current_tenant = nil
      end
    end
  end
end
