# require 'httparty'
require 'CSV'
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
  end

  def process_row(row)
    log_info "@@@ Processing deceased: #{row['שם פרטי של נפטר']}"

      @cemetery_id =  create_or_find_cemetery(row["מיקום בית קברות"])

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

      dp_response = post("#{@hke_url}/deceased_people", dp_data, raise: false )
      return unless dp_response.success?
      dp_id = dp_response["id"]
      log_info "@@@ Deceased: #{row['שם פרטי של נפטר']} id: #{dp_id} processed."

      # Process contact person if exists
      return unless row["שם פרטי איש קשר"] || row["שם משפחה איש קשר"]

      cp_data = {
        first_name: row["שם פרטי איש קשר"],
        last_name: row["שם משפחה איש קשר"],
        email: row["אימייל איש קשר"],
        phone: row["טלפון איש קשר"],
        gender: ((row["מין של איש קשר"] == "זכר") ? "male" : "female")
      }

      cp_response = post("#{@hke_url}/contact_people", cp_data, raise: false)

      return unless cp_response.success?
      cp_id = cp_response["id"]
      log_info "@@@ Contact #{cp_data[:first_name]} contact_id: #{cp_id} for Deceased: #{dp_data[:first_name]} id: #{dp_id} processed."

      # Process relation if exists
      return unless row[0]

      pair = @he_to_en_relations.find { |a| a[0] == row[0] }
      return unless pair

      relation_data = {
        deceased_person_id: dp_response.parsed_response["id"],
        contact_person_id: cp_response.parsed_response["id"],
        relation_of_deceased_to_contact: pair[1]
      }

      relation_response = post("#{@hke_url}/relations",relation_data, raise: false)
      return unless relation_response.success?
      log_info "@@@ Relation between contact #{cp_data[:first_name]} and Deceased: #{dp_data[:first_name]} processed."

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

      if row["שם פרטי איש קשר"] || row["שם משפחה איש קשר"]
        log_info "Data for contact of #{row['שם פרטי של נפטר']} exists."
        if row[0] # The relationship must exist
          pair = @he_to_en_relations.find { |a| a[0] == row[0] }
          if pair
            log_info "Relationship #{pair[1]} exists."
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
          else
            log_info "Relationship #{row[0]} not  valid - not writing contact."
          end
        else
          log_info "Relationship for #{row['שם פרטי של נפטר']} does not exist - not writing contact."
        end
      end

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

      # process_row row
      process_row_as_one row

    end
  end

  def summarize
    log_info "There are #{get_count('deceased_people')} deceased people, and #{get_count('contact_people')} contacts"
    log_error "There were #{@num_errors} errors in input csv file."
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
