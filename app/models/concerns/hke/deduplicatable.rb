module Hke
  module Deduplicatable
    extend ActiveSupport::Concern

    included do
      # You can add additional hooks if needed
    end

    class_methods do
      def deduplication_fields(*fields)
        @deduplication_fields = fields.map(&:to_s)
      end

      def get_deduplication_fields
        @deduplication_fields || []
      end
    end

    def save(*args, **options)
      existing_record = find_existing_record
      if existing_record
        Rails.logger.info("Deduplication: Found existing record for #{self.class.name} with #{deduplication_query(existing_record)}. Returning the existing record.")
        self.id = existing_record.id
        return true  # Mimics a successful save without creating a new record
      end

      Rails.logger.info("Creating new #{self.class.name} record with #{deduplication_query}.")
      super  # Proceed with the normal save process if no duplicate is found
    end

    private

    def find_existing_record
      fields = self.class.get_deduplication_fields
      return if fields.empty?

      query = fields.each_with_object({}) do |field, hash|
        value = send(field)
        next if value.blank?

        hash[field] = value
      end

      query.empty? ? nil : self.class.find_by(query)
    end

    def deduplication_query(record = nil)
      fields = self.class.get_deduplication_fields
      query = fields.each_with_object({}) do |field, hash|
        value = record ? record.send(field) : send(field)
        next if value.blank?

        hash[field] = value
      end
      query.inspect
    end
  end
end
