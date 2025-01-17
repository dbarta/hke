require 'httparty'
require_relative "seeds_helper"

class ApiSeedsExecutor
  include SeedsHelper

  def initialize(max_num_people)
    @max_num_people = max_num_people
    @logger = log("api_import_csv.log")
    @error = log("api_import_csv_errors.log")
    @num_errors = 0
    I18n.locale = :he

    # Initialize API client with separate URLs
    @auth_base_url = "http://localhost:3000/api/v1"
    @api_base_url = "http://localhost:3000/hke/api/v1"
    @api_token = create_api_token
    @headers = {
      "Content-Type" => "application/json",
      "Accept" => "application/json",
      "Authorization" => "Bearer #{@api_token}"
    }
  end

  def create_api_token
    # Create admin user and get API token
    admin_data = {
      name: "admin",
      email: "david@odeca.net",
      password: "password",
      terms_of_service: true,
      admin: true
    }

    response = HTTParty.post(
      "#{@auth_base_url}/auth",
      body: admin_data.to_json,
      headers: {
        "Content-Type" => "application/json",
        "Accept" => "application/json"
      }
    )

    if response.success?
      response.parsed_response["token"]
    else
      raise "Failed to create API token: #{response.body}"
    end
  end

  def create_initial_data
    # Create admin user
    admin_data = {
      name: "admin",
      email: "david@odeca.net",
      password: "password",
      terms_of_service: true,
      admin: true
    }

    user_response = HTTParty.post(
      "#{@auth_base_url}/users",
      body: admin_data.to_json,
      headers: @headers
    )
    check_response(user_response, "user")

    # Create account
    account_data = {
      name: "Hakhel Account",
      owner_id: user_response.parsed_response["id"]
    }
    account_response = HTTParty.post(
      "#{@auth_base_url}/accounts",
      body: account_data.to_json,
      headers: @headers
    )
    check_response(account_response, "account")

    # Create community
    community_data = {
      name: "Kfar Vradim Synagogue",
      community_type: "synagogue",
      account_id: account_response.parsed_response["id"]
    }
    community_response = HTTParty.post(
      "#{@api_base_url}/communities",
      body: community_data.to_json,
      headers: @headers
    )
    check_response(community_response, "community")
  end

  def clear_database

    Hke::FutureMessage.delete_all
    Hke::Relation.delete_all
    Hke::DeceasedPerson.delete_all
    Hke::ContactPerson.delete_all
    Hke::Cemetery.delete_all

    AccountUser.delete_all
    Hke::System.delete_all
    Hke::Community.delete_all

    ApiToken.delete_all

    Account.delete_all
    User.delete_all
    puts "@@@ Database cleared"

    # Create initial data after clearing
    create_initial_data
    puts "@@@ Usr, account and community created"
  end

  def create_users_and_accounts
    # Create system record
    system_data = { product_name: "Hakhel", version: "0.1" }
    response = HTTParty.post(
      "#{@api_base_url}/systems",
      body: system_data.to_json,
      headers: @headers
    )
    check_response(response, "system")

    # Create community
    community_data = {
      name: "Kfar Vradim Synagogue",
      community_type: "synagogue"
    }
    response = HTTParty.post(
      "#{@api_base_url}/communities",
      body: community_data.to_json,
      headers: @headers
    )
    check_response(response, "community")
  end

  def process_csv(file_path)
    @logger.info "Start processing #{file_path}"
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
        "#{@api_base_url}/deceased_people",
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
        "#{@api_base_url}/contact_people",
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
        "#{@api_base_url}/relations",
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
    response = HTTParty.get("#{@api_base_url}/#{resource}/count", headers: @headers)
    response.success? ? response.parsed_response["count"] : 0
  end

  def check_response(response, resource)
    unless response.success?
      @error.error "Failed to create #{resource}: #{response.body}"
      @num_errors += 1
    end
  end

  def log_errors(response, resource)
    @error.error "Errors in row #{@line_no} for #{resource}: #{response.body}"
    @num_errors += 1
  end
end
