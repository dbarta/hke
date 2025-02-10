require 'httparty'
require_relative 'loggable.rb'

module Hke
  module ApiHelper
    include Hke::Loggable

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
      log_info "Returned id: #{response['id']}" if response["id"]
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
      @hakhel_url = "http://localhost:3000/api/v1"
      @hke_url = "http://localhost:3000/hke/api/v1"
      @headers = {"Content-Type" => "application/json", "Accept" => "application/json"}
    end

    def init_api
      init_urls
      login_as_admin
    end

    def create_admin_account_community_system
      init_urls
      # Register new admin user
      response = post("#{@hakhel_url}/users",
          {user: {name: "admin", email: "david@odeca.net", password: "password",
                  terms_of_service: true, admin: true }})
      @user_id = response["id"]

      login_as_admin

      # Create account
      response = post("#{@hakhel_url}/accounts", { account: {name: "Kfar Vradim", owner_id: @user_id, personal: false, billing_email: "david@odeca.net" }})
      @account_id = response["id"]

      # Create community
      post("#{@hke_url}/communities", { community: {name: "Kfar Vradim Synagogue", community_type: "synagogue", account_id: @account_id }})

      # Create system record
      post("#{@hke_url}/system", {system: {product_name: "Hakhel", version: "0.1" }})
    end

    def create_or_find_cemetery(cemetery_name)
      return nil if cemetery_name.nil?

      # Create new cemetery if not found
      response = post("#{@hke_url}/cemeteries", { cemetery: { name: cemetery_name } })
      # log_info "Response from create cemetery: #{response}"
      if response && response["id"]
        log_info "Created cemetery: #{response['name']}"
        response["id"]
      else
        log_error "Failed to create cemetery: #{cemetery_name}"
        nil
      end
    end

  end
end
