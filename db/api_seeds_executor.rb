# require 'httparty'
require 'csv'
require 'set'

require_relative '../lib/hke/api_helper.rb'
require_relative '../lib/hke/log_helper.rb'
require_relative '../lib/hke/loggable.rb'

class ApiSeedsExecutor
  include Hke::ApiHelper
  include Hke::Loggable
  include Hke::ApplicationHelper

  def initialize(max_num_people)
    @max_num_people = max_num_people
    I18n.locale = :he
    @num_errors = 0
    @new_deceased = 0
    @existing_deceased = 0
    @new_contacts = 0
    @existing_contacts = 0
    @total_rows = 0
    @counted_deceased_ids = Set.new
    @counted_contact_ids = Set.new
  end

  def process_row(row)
    log_info "@@@ Processing row #{@line_no}: deceased #{row['שם פרטי של נפטר']} #{row['שם משפחה של נפטר']}"

    @cemetery_id = create_or_find_cemetery(row["מיקום בית קברות"])

    # Process deceased person
    dp_data = {
      first_name: row["שם פרטי של נפטר"],
      last_name: row["שם משפחה של נפטר"],
      hebrew_year_of_death: row["שנת פטירה"],
      hebrew_month_of_death: row["חודש פטירה"],
      hebrew_day_of_death: row["יום פטירה"],
      gender: ((row["מין של נפטר"] == "זכר") ? "male" : "female"),
      father_first_name: row["אבא של נפטר"],
      mother_first_name: row["אמא של נפטר"],
      cemetery_id: @cemetery_id
    }

    dp_response = post("#{@hke_url}/deceased_people", dp_data, raise: false)
    unless dp_response.success?
      cp_full = "#{row['שם פרטי איש קשר']} #{row['שם משפחה איש קשר']}".strip
      log_error "Row #{@line_no}: failed to create deceased '#{dp_data[:first_name]} #{dp_data[:last_name]}' (contact: '#{cp_full}'). Response: #{dp_response.body}"
      @num_errors += 1
      return
    end
    dp_id = dp_response["id"]
    dp_status = dp_response["dedup_status"]
    unless @counted_deceased_ids.include?(dp_id)
      if dp_status == "created"
        @new_deceased += 1
      elsif dp_status == "existing"
        @existing_deceased += 1
      end
      @counted_deceased_ids << dp_id
    end
    log_info "@@@ Deceased '#{dp_data[:first_name]}' id: #{dp_id} (#{dp_status}) processed."

    # Contact + relation must both be valid to proceed
    contact_data_exists = false
    relation_pair = nil
    if row["שם פרטי איש קשר"] || row["שם משפחה איש קשר"]
      if row[0]
        relation_pair = @he_to_en_relations.find { |a| a[0] == row[0] }
        contact_data_exists = true if relation_pair
      end
    end

    unless contact_data_exists
      cp_full = "#{row['שם פרטי איש קשר']} #{row['שם משפחה איש קשר']}".strip
      log_error "Row #{@line_no}: missing or invalid contact/relationship for deceased '#{dp_data[:first_name]} #{dp_data[:last_name]}'. Contact: '#{cp_full}'."
      @num_errors += 1
      return
    end

    cp_data = {
      first_name: row["שם פרטי איש קשר"],
      last_name: row["שם משפחה איש קשר"],
      email: row["אימייל איש קשר"],
      phone: row["טלפון איש קשר"],
      gender: ((row["מין של איש קשר"] == "זכר") ? "male" : "female")
    }

    cp_response = post("#{@hke_url}/contact_people", cp_data, raise: false)
    unless cp_response.success?
      log_error "Row #{@line_no}: failed to create contact '#{cp_data[:first_name]} #{cp_data[:last_name]}' for deceased '#{dp_data[:first_name]} #{dp_data[:last_name]}'. Response: #{cp_response.body}"
      @num_errors += 1
      return
    end
    cp_id = cp_response["id"]
    cp_status = cp_response["dedup_status"]
    unless @counted_contact_ids.include?(cp_id)
      if cp_status == "created"
        @new_contacts += 1
      elsif cp_status == "existing"
        @existing_contacts += 1
      end
      @counted_contact_ids << cp_id
    end
    log_info "@@@ Contact '#{cp_data[:first_name]}' id: #{cp_id} (#{cp_status}) for deceased '#{dp_data[:first_name]}' processed."

    relation_data = {
      deceased_person_id: dp_id,
      contact_person_id: cp_id,
      relation_of_deceased_to_contact: relation_pair[1]
    }

    relation_response = post("#{@hke_url}/relations", relation_data, raise: false)
    unless relation_response.success?
      log_error "Row #{@line_no}: failed to create relation '#{relation_pair[1]}' between contact '#{cp_data[:first_name]} #{cp_data[:last_name]}' and deceased '#{dp_data[:first_name]} #{dp_data[:last_name]}'. Response: #{relation_response.body}"
      @num_errors += 1
      return
    end
    rel_status = relation_response["dedup_status"]
    log_info "@@@ Relation (#{relation_data[:relation_of_deceased_to_contact]}) created/used (#{rel_status}) for deceased '#{dp_data[:first_name]}' and contact '#{cp_data[:first_name]}'."

    sleep(0.1) # Maintain rate limiting
  end

  def process_row_as_one(row)
    log_info "@@@ Processing deceased: #{row['שם פרטי של נפטר']}"

      @cemetery_id =  create_or_find_cemetery(row["מיקום בית קברות"])

      # Process deceased person
      dp_data = {   deceased_person:
                    {
                      first_name: row["שם פרטי של נפטר"],
                      last_name: row["שם משפחה של נפטר"],
                      hebrew_year_of_death: row["שנת פטירה"],
                      hebrew_month_of_death: row["חודש פטירה"],
                      hebrew_day_of_death: row["יום פטירה"],
                      gender: ((row["מין של נפטר"] == "זכר") ? "male" : "female"),
                      father_first_name: row["אבא של נפטר"],
                      mother_first_name: row["אמא של נפטר"],
                      cemetery_id: @cemetery_id
                    }
      }

      contact_data_exists = false
      if row["שם פרטי איש קשר"] || row["שם משפחה איש קשר"]
        if row[0] # The relationship must exist
          pair = @he_to_en_relations.find { |a| a[0] == row[0] }
          if pair
            log_info "CSV file contains valid contact info for  #{row['שם פרטי של נפטר']}  with relationship  #{pair[1]}."
            contact_data_exists = true
            dp_data[:deceased_person][:relations_attributes] =
              [
                {
                  relation_of_deceased_to_contact: pair[1],
                  contact_person_attributes:
                  {
                    first_name: row["שם פרטי איש קשר"],
                    last_name: row["שם משפחה איש קשר"],
                    email: row["אימייל איש קשר"],
                    phone: row["טלפון איש קשר"],
                    gender: ((row["מין של איש קשר"] == "זכר") ? "male" : "female")
                  }
                }
              ]
          end
        end
      end
      log_error "Missing or invalid contact info for: #{row['שם פרטי של נפטר']}. " if !contact_data_exists

      dp_response = post("#{@hke_url}/deceased_people", dp_data, raise: false )
      log_info "@@@ Deceased: #{row['שם פרטי של נפטר']} id: #{dp_response[:id]} processed."

      sleep(0.1) # Maintain rate limiting
  end

  def process_csv(file_path)
    log_info "@@@ Start processing #{file_path}"
    init_api
    @he_to_en_relations = relations_select

    csv_text = File.read(file_path)
    csv = CSV.parse(csv_text, headers: true, encoding: "UTF-8")
    csv.each_with_index do |row, index|
      @line_no = index + 1
      break if @line_no > @max_num_people
      @total_rows += 1
      process_row row
    end
  end

  def summarize
    ok_rows = @total_rows - @num_errors
    log_info "Rows: total #{@total_rows}, ok #{ok_rows}, errors #{@num_errors}"
    log_info "New deceased: #{@new_deceased}, existing deceased: #{@existing_deceased}"
    log_info "New contacts: #{@new_contacts}, existing contacts: #{@existing_contacts}"
  end

  private

  def get_count(resource)
    response = HTTParty.get("#{@hke_url}/#{resource}/count", headers: @headers)
    response.success? ? response.parsed_response["count"] : 0
  end

  def log_errors(response, resource)
    @error.error "Errors in row #{@line_no} for #{resource}: #{response.body}"
    @num_errors += 1
  end
end
