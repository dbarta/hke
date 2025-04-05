# hke/app/jobs/hke/future_message_send_job.rb

module Hke
  class SendMessageJob < ApplicationJob
    queue_as :default

    def perform
      Hke::FutureMessage.send_due_messages
    end
  end
end
