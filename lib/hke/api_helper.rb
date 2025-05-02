require 'httparty'
require_relative 'loggable.rb'

module Hke
  module ApiHelper
    include Hke::Loggable


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
          Hke::Log,
          ApiToken,
          Account,
          User,
      ].each do |model|
        model.delete_all
        log_info "@@@ Database table for: #{model.to_s} successfully cleared."
      end
      log_info "@@@ All Hakhel database tables successfully cleared."
    end

    def check_response(request_body, response, raise: true)
      if !response.success?
        log_error "Failed call, code: #{response.code} with: #{request_body}"
        if response.body['errors']
          response.body['errors'].each do |field, messages|
            messages.each {|message| log_error "#{field.capitalize}: #{message}"}
          end
        end
        raise "@@@ RAISED: API call failed." if raise
      end
      # log_info "Successful Api call with #{request_body}. response: #{response.inspect}"
      return response
    end

    def post(url, body, raise: true)
      response = HTTParty.post(url, body: body.to_json, headers: @headers, format: :json)
      check_response(body, response, raise: raise)
    end

    def get(url, body, raise: true)
      response = HTTParty.get(url, body: body.to_json, headers: @headers)
      check_response(body, response, raise: raise)
    end

    def login_as_admin
      response = post("#{@hakhel_url}/auth", {email: "david@odeca.net", password: "password"})
      @headers["Authorization"] = "Bearer #{response["token"]}"
    end

    def init_urls
      @API_URL = ENV.fetch("HAKHEL_BASE_URL", "http://localhost:3000")
      @hakhel_url = "#{@API_URL}/api/v1"
      @hke_url = "#{@API_URL}/hke/api/v1"
      @headers = {"Content-Type" => "application/json", "Accept" => "application/json"}
    end

    def init_api
      init_urls
      login_as_admin
    end

    def create_admin_account_community_system
      init_urls
      # Register new admin user
      admin_name = "admin"
      response = post("#{@hakhel_url}/users",
          {user: {name: admin_name, email: "david@odeca.net", password: "password",
                  terms_of_service: true, admin: true }})
      @user_id = response["user"]["id"]
      log_info "@@@ user: '#{admin_name}' successfully registered with id: #{@user_id}."

      login_as_admin
      log_info "@@@ user: '#{admin_name}' successfully logged in. Got an API token."

      # Create account
      account_name = "Kfar Vradim"
      response = post("#{@hakhel_url}/accounts", { account: {name: account_name, owner_id: @user_id, personal: false, billing_email: "david@odeca.net" }})
      log_info "@@@ account response: #{response}"
      @account_id = response["id"]
      log_info "@@@ Account: '#{account_name}' successfully created with id: #{@account_id}."

      # Create community
      community_name = "Kfar Vradim Synagogue"
      post("#{@hke_url}/communities", { community: {name: community_name, community_type: "synagogue", account_id: @account_id }})
      @community_id = response["id"]
      log_info "@@@ Community: '#{community_name}' successfully created with id: #{@community_id}."

      # Create system record
      product_name = "Hakhel"
      product_version = "0.1"
      post("#{@hke_url}/system", {system: {product_name: "Hakhel", version: "0.1" }})
      log_info "@@@ System record with product: '#{product_name}', version: #{product_version} successfully created."
    end

    def create_or_find_cemetery(cemetery_name)
      return nil if cemetery_name.nil?

      # Create new cemetery if not found
      response = post("#{@hke_url}/cemeteries", { cemetery: { name: cemetery_name } })
      # log_info "Response from create cemetery: #{response}"
      if response && response["id"]
        response["id"]
      else
        log_error "Failed to create cemetery: #{cemetery_name}"
        nil
      end
    end

  end
end
