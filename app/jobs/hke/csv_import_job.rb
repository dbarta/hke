require 'csv'

module Hke
  class CsvImportJob
    include Sidekiq::Job
    include Hke::ApplicationHelper

    def perform(csv_import_id)
      csv_import = CsvImport.find(csv_import_id)
      csv_import.update!(status: :processing)

      # Set locale to Hebrew for translations in background job
      I18n.with_locale(:he) do
        # Set tenant context
        ActsAsTenant.with_tenant(csv_import.community) do
          process_csv_import(csv_import)
        end
      end
    rescue StandardError => e
      csv_import&.update!(status: :failed)
      Hke::Logger.log(event_type: 'csv_import_failed', details: { csv_import_id: csv_import_id, error_message: e.message }, error: e)
      raise
    end

    private

    def process_csv_import(csv_import)
      csv_import.file.open do |io|
        file_path = io.path

        # Count total rows first
        total_rows = count_csv_rows(file_path)
        csv_import.update!(total_rows: total_rows)

        processed = 0
        successful = 0
        failed = 0
        total_deceased_in_input = 0
        total_contacts_in_input = 0
        new_deceased = 0
        existing_deceased = 0

        CSV.foreach(file_path, headers: true, encoding: 'bom|utf-8').with_index(2) do |row, line_number|
          begin
            dp, contact_status, contact_warning, is_new = import_unified_row(row, csv_import)

            # Track statistics
            total_deceased_in_input += 1
            if contact_status == :with_contact
              total_contacts_in_input += 1
            end
            if is_new
              new_deceased += 1
            else
              existing_deceased += 1
            end
            # Per-row logs
            deceased_log = "יובא נפטר: #{dp.first_name} #{dp.last_name}"
            if is_new
              deceased_log += " (חדש)"
            else
              deceased_log += " (קיים)"
            end
            csv_import.logs.create!(level: 'info', row_number: line_number, message: deceased_log)

            if contact_warning
              csv_import.logs.create!(level: 'error', row_number: line_number, message: 'נמצאו פרטי איש קשר אך קשר קרבה חסר/לא תקין — דילוג על יצירת קשר')
            elsif contact_status == :with_contact
              # Get contact details from the relation
              contact = dp.relations.last&.contact_person
              if contact
                relation_type = dp.relations.last&.relation_of_deceased_to_contact
                contact_log = "נוסף איש קשר וקשר קרבה: #{contact.first_name} #{contact.last_name} (#{relation_type})"
                csv_import.logs.create!(level: 'info', row_number: line_number, message: contact_log)
              else
                csv_import.logs.create!(level: 'info', row_number: line_number, message: 'נוסף איש קשר וקשר קרבה')
              end
            end

            successful += 1
          rescue StandardError => e
            failed += 1
            csv_import.add_error(line_number, e.message)
            csv_import.logs.create!(level: 'error', row_number: line_number, message: e.message)
            Hke::Logger.log(event_type: 'csv_import_row_error', details: {
              csv_import_id: csv_import.id,
              line_number: line_number,
              error_message: e.message
            }, error: e)
          end

          processed += 1

          # Update progress after every record for real-time feedback
          csv_import.update!(
            processed_rows: processed,
            successful_rows: successful,
            failed_rows: failed,
            total_deceased_in_input: total_deceased_in_input,
            total_contacts_in_input: total_contacts_in_input,
            new_deceased: new_deceased,
            existing_deceased: existing_deceased
          )

          # Broadcast update via Turbo for real-time UI updates
          # Reload to ensure fresh data for broadcast
          csv_import.reload
          csv_import.broadcast_replace_to(
            csv_import,
            partial: "hke/csv_imports/csv_import",
            locals: { csv_import: csv_import }
          )
        end

        # Final update
        csv_import.update!(
          processed_rows: processed,
          successful_rows: successful,
          failed_rows: failed,
          total_deceased_in_input: total_deceased_in_input,
          total_contacts_in_input: total_contacts_in_input,
          new_deceased: new_deceased,
          existing_deceased: existing_deceased,
          status: :completed
        )

        # Final broadcast
        # Reload to ensure fresh data for broadcast
        csv_import.reload
        csv_import.broadcast_replace_to(
          csv_import,
          partial: "hke/csv_imports/csv_import",
          locals: { csv_import: csv_import }
        )

        Hke::Logger.log(event_type: 'csv_import_completed', details: {
          csv_import_id: csv_import.id,
          total_rows: total_rows,
          successful: successful,
          failed: failed
        })
      end
    end

    def count_csv_rows(file_path)
      CSV.foreach(file_path, headers: true, encoding: 'bom|utf-8').count
    rescue StandardError
      0
    end
    def import_unified_row(row, csv_import)
      relation_he = hv(row, 'relation', 'קשר', 'קשר לנפטר', 'relation_to_deceased')
      relation_he ||= row[0]
      relation_pair = relations_select.find { |pair| pair[0] == relation_he }
      relation_en = relation_pair ? relation_pair[1] : nil

      dp_attrs = {
        first_name: hv(row, 'first_name', 'שם פרטי של נפטר'),
        last_name: hv(row, 'last_name', 'שם משפחה של נפטר'),
        gender: normalize_gender(hv(row, 'gender', 'מין של נפטר')),
        father_first_name: hv(row, 'father_first_name', 'אבא של נפטר'),
        mother_first_name: hv(row, 'mother_first_name', 'אמא של נפטר'),
        hebrew_year_of_death: hv(row, 'hebrew_year_of_death', 'שנת פטירה'),
        hebrew_month_of_death: hv(row, 'hebrew_month_of_death', 'חודש פטירה'),
        hebrew_day_of_death: hv(row, 'hebrew_day_of_death', 'יום פטירה'),
        date_of_death: parse_date(hv(row, 'date_of_death', 'תאריך פטירה לועזי')),
        cemetery_id: find_or_create_cemetery_id(hv(row, 'cemetery_name', 'מיקום בית קברות'))
      }

      has_contact_data = [
        hv(row, 'contact_first_name', 'שם פרטי איש קשר'),
        hv(row, 'contact_last_name', 'שם משפחה איש קשר'),
        hv(row, 'contact_email', 'אימייל איש קשר'),
        hv(row, 'contact_phone', 'טלפון איש קשר'),
        hv(row, 'contact_gender', 'מין של איש קשר')
      ].compact.any?

      rel_attrs = {}
      if relation_en.present? && has_contact_data
        rel_attrs = {
          relations_attributes: [
            {
              relation_of_deceased_to_contact: relation_en,
              contact_person_attributes: {
                first_name: hv(row, 'contact_first_name', 'שם פרטי איש קשר'),
                last_name: hv(row, 'contact_last_name', 'שם משפחה איש קשר'),
                email: hv(row, 'contact_email', 'אימייל איש קשר'),
                phone: hv(row, 'contact_phone', 'טלפון איש קשר'),
                gender: normalize_gender(hv(row, 'contact_gender', 'מין של איש קשר'))
              }
            }
          ]
        }
      end

      # Check if deceased person already exists
      existing_dp = DeceasedPerson.find_by(
        first_name: dp_attrs[:first_name],
        last_name: dp_attrs[:last_name],
        hebrew_year_of_death: dp_attrs[:hebrew_year_of_death],
        hebrew_month_of_death: dp_attrs[:hebrew_month_of_death],
        hebrew_day_of_death: dp_attrs[:hebrew_day_of_death]
      )

      if existing_dp
        # Record already exists - don't update, just count it
        dp = existing_dp
        is_new = false
      else
        # Create new record
        dp = DeceasedPerson.new(dp_attrs.merge(rel_attrs))
        dp.save!
        is_new = true
      end

      contact_status = rel_attrs.present? ? :with_contact : :without_contact
      contact_warning = has_contact_data && relation_en.blank?
      [dp, contact_status, contact_warning, is_new]
    end


    def import_deceased_person(row, csv_import)
      attrs = {
        first_name: hv(row, 'first_name', 'שם פרטי של נפטר'),
        last_name: hv(row, 'last_name', 'שם משפחה של נפטר'),
        gender: normalize_gender(hv(row, 'gender', 'מין של נפטר')),
        father_first_name: hv(row, 'father_first_name', 'אבא של נפטר'),
        mother_first_name: hv(row, 'mother_first_name', 'אמא של נפטר'),
        hebrew_year_of_death: hv(row, 'hebrew_year_of_death', 'שנת פטירה'),
        hebrew_month_of_death: hv(row, 'hebrew_month_of_death', 'חודש פטירה'),
        hebrew_day_of_death: hv(row, 'hebrew_day_of_death', 'יום פטירה'),
        date_of_death: parse_date(hv(row, 'date_of_death', 'תאריך פטירה לועזי')),
        cemetery_id: find_or_create_cemetery_id(hv(row, 'cemetery_name', 'מיקום בית קברות'))
      }

      dp = DeceasedPerson.new(attrs)
      dp.save!
      dp
    end

    def import_contact_person(row, csv_import)
      attrs = {
        first_name: hv(row, 'first_name', 'שם פרטי איש קשר'),
        last_name: hv(row, 'last_name', 'שם משפחה איש קשר'),
        phone: hv(row, 'phone', 'טלפון איש קשר'),
        email: hv(row, 'email', 'אימייל איש קשר'),
        gender: normalize_gender(hv(row, 'gender', 'מין של איש קשר'))
      }

      cp = ContactPerson.new(attrs)
      cp.save!
      cp
    end

    def import_combined_record(row, csv_import)
      relation_he = hv(row, 'relation', 'קשר', 'קשר לנפטר', 'relation_to_deceased')
      relation_he ||= row[0]
      relation_pair = relations_select.find { |pair| pair[0] == relation_he }
      relation_en = relation_pair ? relation_pair[1] : nil

      dp_attrs = {
        first_name: hv(row, 'first_name', 'שם פרטי של נפטר'),
        last_name: hv(row, 'last_name', 'שם משפחה של נפטר'),
        gender: normalize_gender(hv(row, 'gender', 'מין של נפטר')),
        father_first_name: hv(row, 'father_first_name', 'אבא של נפטר'),
        mother_first_name: hv(row, 'mother_first_name', 'אמא של נפטר'),
        hebrew_year_of_death: hv(row, 'hebrew_year_of_death', 'שנת פטירה'),
        hebrew_month_of_death: hv(row, 'hebrew_month_of_death', 'חודש פטירה'),
        hebrew_day_of_death: hv(row, 'hebrew_day_of_death', 'יום פטירה'),
        date_of_death: parse_date(hv(row, 'date_of_death', 'תאריך פטירה לועזי')),
        cemetery_id: find_or_create_cemetery_id(hv(row, 'cemetery_name', 'מיקום בית קברות'))
      }

      rel_attrs = {}
      if relation_en
        rel_attrs = {
          relations_attributes: [
            {
              relation_of_deceased_to_contact: relation_en,
              contact_person_attributes: {
                first_name: hv(row, 'contact_first_name', 'שם פרטי איש קשר'),
                last_name: hv(row, 'contact_last_name', 'שם משפחה איש קשר'),
                email: hv(row, 'contact_email', 'אימייל איש קשר'),
                phone: hv(row, 'contact_phone', 'טלפון איש קשר'),
                gender: normalize_gender(hv(row, 'contact_gender', 'מין של איש קשר'))
              }
            }
          ]
        }
      end

      dp = DeceasedPerson.new(dp_attrs.merge(rel_attrs))
      dp.save!
      dp
    end

    def parse_date(date_string)
      return nil if date_string.blank?
      str = date_string.to_s.strip
      begin
        Date.parse(str)
      rescue Date::Error
        nil
      end
    end

    # Helper: get first non-blank value by keys
    def hv(row, *keys)
      keys.each do |k|
        v = row[k]
        return v.to_s.strip if v.present?
      end
      nil
    end

    def normalize_gender(value)
      return nil if value.blank?
      v = value.to_s.strip
      return 'male' if %w[m male].include?(v.downcase) || v == 'זכר'
      return 'female' if %w[f female].include?(v.downcase) || v == 'נקבה'
      pair = gender_select.find { |p| p[0] == v }
      pair ? pair[1] : nil
    end

    def find_or_create_cemetery_id(name)
      return nil if name.blank?
      n = name.to_s.strip
      Cemetery.find_or_create_by!(name: n).id
    end
  end
end
