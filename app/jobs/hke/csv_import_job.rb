require 'csv'

module Hke
  class CsvImportJob
    include Sidekiq::Job
    include Hke::Loggable

    def perform(csv_import_id)
      csv_import = CsvImport.find(csv_import_id)
      csv_import.update!(status: :processing)

      # Set tenant context
      ActsAsTenant.with_tenant(csv_import.community) do
        process_csv_import(csv_import)
      end
    rescue StandardError => e
      csv_import&.update!(status: :failed)
      log_error "CSV Import Job failed: #{e.message}", { csv_import_id: csv_import_id, error: e.backtrace }
      raise
    end

    private

    def process_csv_import(csv_import)
      file_path = ActiveStorage::Blob.service.path_for(csv_import.file.key)
      
      # Count total rows first
      total_rows = count_csv_rows(file_path)
      csv_import.update!(total_rows: total_rows)

      processed = 0
      successful = 0
      failed = 0

      CSV.foreach(file_path, headers: true, encoding: 'UTF-8').with_index(2) do |row, line_number|
        begin
          case csv_import.import_type
          when 'deceased_people'
            import_deceased_person(row, csv_import)
          when 'contact_people'
            import_contact_person(row, csv_import)
          when 'combined'
            import_combined_record(row, csv_import)
          end
          
          successful += 1
        rescue StandardError => e
          failed += 1
          csv_import.add_error(line_number, e.message)
          log_error "CSV Import row error", { 
            csv_import_id: csv_import.id, 
            line_number: line_number, 
            error: e.message 
          }
        end

        processed += 1
        
        # Update progress every 10 rows
        if processed % 10 == 0
          csv_import.update!(
            processed_rows: processed,
            successful_rows: successful,
            failed_rows: failed
          )
        end
      end

      # Final update
      csv_import.update!(
        processed_rows: processed,
        successful_rows: successful,
        failed_rows: failed,
        status: :completed
      )

      log_info "CSV Import completed", {
        csv_import_id: csv_import.id,
        total_rows: total_rows,
        successful: successful,
        failed: failed
      }
    end

    def count_csv_rows(file_path)
      CSV.foreach(file_path, headers: true).count
    rescue StandardError
      0
    end

    def import_deceased_person(row, csv_import)
      deceased_person = DeceasedPerson.new(
        first_name: row['first_name']&.strip,
        last_name: row['last_name']&.strip,
        hebrew_year_of_death: row['hebrew_year_of_death']&.strip,
        hebrew_month_of_death: row['hebrew_month_of_death']&.strip,
        hebrew_day_of_death: row['hebrew_day_of_death']&.strip,
        date_of_death: parse_date(row['date_of_death']),
        cemetery_id: find_cemetery_id(row['cemetery_name'])
      )

      unless deceased_person.save
        raise "Failed to save deceased person: #{deceased_person.errors.full_messages.join(', ')}"
      end
    end

    def import_contact_person(row, csv_import)
      contact_person = ContactPerson.new(
        first_name: row['first_name']&.strip,
        last_name: row['last_name']&.strip,
        phone: row['phone']&.strip,
        email: row['email']&.strip,
        relation_to_deceased: row['relation_to_deceased']&.strip
      )

      unless contact_person.save
        raise "Failed to save contact person: #{contact_person.errors.full_messages.join(', ')}"
      end
    end

    def import_combined_record(row, csv_import)
      # Import both deceased and contact person with relationship
      deceased_person = import_deceased_person(row, csv_import)
      
      contact_person = ContactPerson.new(
        first_name: row['contact_first_name']&.strip,
        last_name: row['contact_last_name']&.strip,
        phone: row['contact_phone']&.strip,
        email: row['contact_email']&.strip,
        relation_to_deceased: row['relation_to_deceased']&.strip
      )

      unless contact_person.save
        raise "Failed to save contact person: #{contact_person.errors.full_messages.join(', ')}"
      end

      # Create relationship between deceased and contact
      # This would depend on your relationship model structure
    end

    def parse_date(date_string)
      return nil if date_string.blank?
      Date.parse(date_string.strip)
    rescue Date::Error
      nil
    end

    def find_cemetery_id(cemetery_name)
      return nil if cemetery_name.blank?
      cemetery = Cemetery.find_by(name: cemetery_name.strip)
      cemetery&.id
    end
  end
end
