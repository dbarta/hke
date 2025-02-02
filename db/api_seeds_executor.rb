require 'httparty'
require_relative "api_seeds_helper"

class ApiSeedsExecutor
  include ApiSeedsHelper

  def initialize(max_num_people)
    @max_num_people = max_num_people
    @logger = log("api_import_csv.log")
    @error = log("api_import_csv_errors.log")
    @num_errors = 0
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
      puts "@@@ #{model.to_s} cleared"
    end
     puts "@@@ Database cleared"
  end

  def post(url, body)
    response = HTTParty.post(url, body: body.to_json, headers: @headers)
    check_response(body, response)
    return response
  end

  def register_admin_user
    response = post("#{@hakhel_url}/users",
      {user: {name: "admin", email: "david@odeca.net", password: "password", terms_of_service: true, admin: true }})
    response["id"]
  end

  def login_as_admin
    response = post("#{@hakhel_url}/auth", {email: "david@odeca.net", password: "password"})
    @headers["Authorization"] = "Bearer #{response["token"]}"
  end


  # Initialize API client with URLs, login or create admin user
  def init_api_client
    @hakhel_url = "http://localhost:3000/api/v1"
    @hke_url = "http://localhost:3000/hke/api/v1"
    @headers = {"Content-Type" => "application/json", "Accept" => "application/json"}
    begin
      login_as_admin
      puts "@@@ Admin logged in"
    rescue => e
      puts "@@@ Rescued: #{e.message}"
      @user_id = register_admin_user
      puts "@@@ Admin user registered"
      login_as_admin
      puts "@@@ Admin user logged in, token received"

      # Create account
      response = post("#{@hakhel_url}/accounts", { account: {name: "Kfar Vradim", owner_id: @user_id, personal: false, billing_email: "david@odeca.net" }})
      @account_id = response["id"]
      puts "@@@ Account created"

      # Create community
      post("#{@hke_url}/communities", { community: {name: "Kfar Vradim Synagogue", community_type: "synagogue", account_id: @account_id }})
       puts "@@@ Community created"
      # Create system record
      post("#{@hke_url}/system", {system: {product_name: "Hakhel", version: "0.1" }})
       puts "@@@ System created"
    end
  end

  def process_csv(file_path)
    @logger.info "Start processing #{file_path}"
    init_api_client
    he_to_en_relations = relations_select

    csv_text = File.read(file_path)
    csv = CSV.parse(csv_text, headers: true, encoding: "UTF-8")
    csv.each_with_index do |row, index|
      @line_no = index + 2
      break if @line_no > @max_num_people

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
        cemetery_id: create_or_find_cemetery(row["מיקום בית קברות"])
      }

      dp_response = HTTParty.post(
        "#{@hke_url}/deceased_people",
        body: dp_data.to_json,
        headers: @headers
      )

      unless dp_response.success?
        log_errors(dp_response, "deceased person")
        next
      end

      # Process contact person if exists
      next unless row["שם פרטי איש קשר"] || row["שם משפחה איש קשר"]

      cp_data = {
        first_name: row["שם פרטי איש קשר"],
        last_name: row["שם משפחה איש קשר"],
        email: row["אימייל איש קשר"],
        phone: row["טלפון איש קשר"],
        gender: ((row["מין של איש קשר"] == "זכר") ? "male" : "female")
      }

      cp_response = HTTParty.post(
        "#{@hke_url}/contact_people",
        body: cp_data.to_json,
        headers: @headers
      )

      unless cp_response.success?
        log_errors(cp_response, "contact person")
        next
      end

      # Process relation if exists
      next unless row[0]

      pair = he_to_en_relations.find { |a| a[0] == row[0] }
      next unless pair

      relation_data = {
        deceased_person_id: dp_response.parsed_response["id"],
        contact_person_id: cp_response.parsed_response["id"],
        relation_of_deceased_to_contact: pair[1]
      }

      relation_response = HTTParty.post(
        "#{@hke_url}/relations",
        body: relation_data.to_json,
        headers: @headers
      )

      unless relation_response.success?
        log_errors(relation_response, "relation")
        next
      end

      sleep(0.1) # Maintain rate limiting
    end
  end

  def summarize
    @logger.info "There are #{get_count('deceased_people')} deceased people, and #{get_count('contact_people')} contacts"
    @error.info "There were #{@num_errors} errors in input csv file."
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
