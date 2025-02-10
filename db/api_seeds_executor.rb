require 'httparty'
require 'CSV'
require_relative '../lib/hke/log_helper.rb'
require_relative '../lib/hke/api_helper.rb'

class ApiSeedsExecutor
  include Hke::ApiHelper
  include Hke::LogHelper
  include Hke::ApplicationHelper

  def initialize(max_num_people)
    @max_num_people = max_num_people
    init_logging "api_import_csv"
    I18n.locale = :he
  end

  def clear_database
    [
        Hke::FutureMessage,
        Hke::Relation,
        Hke::DeceasedPerson,
        Hke::ContactPerson,
        Hke::Cemetery,
        AccountUser,
        Hke::System,
        Hke::Community,
        ApiToken,
        Account,
        User,
    ].each do |model|
      model.delete_all
      log_info "#{model.to_s} cleared"
    end
    log_info "Database cleared"
  end

  def process_csv(file_path)
    log_info "Start processing #{file_path}"
    init_api
    he_to_en_relations = relations_select

    csv_text = File.read(file_path)
    csv = CSV.parse(csv_text, headers: true, encoding: "UTF-8")
    csv.each_with_index do |row, index|
      @line_no = index + 1
      break if @line_no > @max_num_people
      log_info("@@@ Processing deceased: #{row['שם פרטי של נפטר']}")
      @cemetery_id =  create_or_find_cemetery(row["מיקום בית קברות"])
      log_info "@@@ cemetery_id: #{@cemetery_id}"

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
      next unless dp_response.success?
      dp_id = dp_response["id"]
      log_info "@@@ Deceased id: #{dp_id}"

      # Process contact person if exists
      next unless row["שם פרטי איש קשר"] || row["שם משפחה איש קשר"]

      cp_data = {
        first_name: row["שם פרטי איש קשר"],
        last_name: row["שם משפחה איש קשר"],
        email: row["אימייל איש קשר"],
        phone: row["טלפון איש קשר"],
        gender: ((row["מין של איש קשר"] == "זכר") ? "male" : "female")
      }

      cp_response = post("#{@hke_url}/contact_people", cp_data, raise: false)
      next unless cp_response.success?
      cp_id = cp_response["id"]
      log_info "@@@ Contact id: #{cp_id}"

      # Process relation if exists
      next unless row[0]

      pair = he_to_en_relations.find { |a| a[0] == row[0] }
      next unless pair

      relation_data = {
        deceased_person_id: dp_response.parsed_response["id"],
        contact_person_id: cp_response.parsed_response["id"],
        relation_of_deceased_to_contact: pair[1]
      }

      relation_response = post("#{@hke_url}/relations",relation_data, raise: false)
      next unless relation_response.success?

      sleep(0.1) # Maintain rate limiting
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
