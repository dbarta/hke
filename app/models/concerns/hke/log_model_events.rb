module Hke
  module LogModelEvents
    extend ActiveSupport::Concern

    included do
      after_create  { log_model_event("create", self.attributes) }
      after_update  { log_model_event("update", saved_changes.except(:updated_at)) }
      after_destroy { log_model_event("destroy", self.attributes) }
    end

    private

    def log_model_event(event_type, data)
      Hke::Logger.log(
        event_type: event_type,
        entity: self,
        details: data
      )
    end
  end
end
