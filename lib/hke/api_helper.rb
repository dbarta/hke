require 'httparty'
require_relative 'loggable.rb'

module Hke
  module ApiHelper
    include Hke::Loggable


    def clear_database
      # Clear Sidekiq queues first to avoid orphaned jobs
      clear_sidekiq

      # Clear any user community assignments to break foreign key constraints
      if User.table_exists?
        users_with_community = User.where.not(community_id: nil).count
        log_info "@@@ Found #{users_with_community} users with community assignments."

        if users_with_community > 0
          # Temporarily disable foreign key constraint to allow nullifying
          ActiveRecord::Base.connection.execute("SET session_replication_role = replica;")
          User.update_all(community_id: nil)
          ActiveRecord::Base.connection.execute("SET session_replication_role = DEFAULT;")
          log_info "@@@ Cleared community_id for #{users_with_community} users."
        else
          log_info "@@@ No users with community assignments found."
        end
      end

      [
          Hke::FutureMessage,    # No dependencies
          Hke::SentMessage,      # No dependencies
          Hke::Relation,         # References DeceasedPerson/ContactPerson
          Hke::DeceasedPerson,   # References Cemetery/Community
          Hke::ContactPerson,    # References Community
          Hke::Cemetery,         # References Community
          Hke::System,           # No dependencies
          Hke::Log,              # No dependencies
          ApiToken,              # References User
          AccountUser,           # References Account + User
          Hke::Community,        # References Account (delete before Account)
          Account,               # References User (delete before User)
          User,                  # Delete last
      ].each do |model|
        model.delete_all
        log_info "@@@ Database table for: #{model.to_s} successfully cleared."
      end
      log_info "@@@ All Hakhel database tables successfully cleared."
    end

    def clear_sidekiq
      begin
        require 'sidekiq/api'

        # Clear all Sidekiq queues and jobs
        Sidekiq::Queue.new.clear
        Sidekiq::RetrySet.new.clear
        Sidekiq::DeadSet.new.clear
        Sidekiq::ScheduledSet.new.clear

        log_info "@@@ All Sidekiq queues successfully cleared."
      rescue LoadError
        log_info "@@@ Sidekiq not available - skipping queue clearing."
      rescue => e
        log_error "@@@ Error clearing Sidekiq queues: #{e.message}"
      end
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
      response = post("#{@hakhel_url}/auth", {email: "david@odeca.net", password: "odeca111"})
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
      # Register new admin user with new role system
      response = post("#{@hakhel_url}/users",
          {user: {
            first_name: "David",
            last_name: "Barta",
            email: "david@odeca.net",
            password: "odeca111",
            terms_of_service: true,
            roles: { system_admin: true, community_admin: false, community_user: false }
          }})
      @user_id = response["user"]["id"]
      log_info "@@@ user: 'David Barta' successfully registered with id: #{@user_id}."

      login_as_admin
      log_info "@@@ user: 'David Barta' successfully logged in. Got an API token."

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
      post("#{@hke_url}/system", {system: {product_name: product_name, version: product_version }})
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
