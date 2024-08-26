require "rack/utils"
module TestApiHelper
  def symbol_to_status_code(symbol)
    Rack::Utils::SYMBOL_TO_STATUS_CODE[symbol]
  end

  def status_code_to_symbol(code)
    Rack::Utils::HTTP_STATUS_CODES[code].downcase.gsub(/\s|-/, "_").to_sym
  end

  def make_api_call(method, url, body, description, expected_status)
    api_logger.info "STARTED: #{description}, Request:\n#{JSON.pretty_generate(body)}"
    send(method, url, params: body.to_json, headers: {"Authorization" => "Bearer #{token}", "Content-Type" => "application/json"})

    actual_status = response.status
    status_message = (actual_status === symbol_to_status_code(expected_status)) ? "as expected." : "NOT as expected. Expected: #{expected_status}, got: #{actual_status}"
    sts_msg = "Response status: #{actual_status} #{status_message}"
    # Log the response if available

    if respond_to?(:response) && response.present? && !response.body.empty?
      begin
        parsed_body = JSON.parse(response.body)
        msg = "Response:\n #{JSON.pretty_generate(parsed_body)}"
      rescue JSON::ParserError
        msg = "Received non-JSON response:#{response.body}"
      end
    else
      msg = "No response body."
    end

    api_logger.info msg
    api_logger.info "ENDED: #{description}, #{sts_msg}"
  end

  def create_deceased_person(json, description)
    make_api_call :post, create_deceased_person_url, json, description, :created
  end

  def ensure_user_and_get_token
    # Attempt to login
    post auth_url, params: login_json
    if response.status == :ok || reponse.status == 200
      # If login is successful, return the token
      JSON.parse(response.body)["token"]
    elsif response.status == 401
      # If unauthorized, attempt to register the user
      post register_url, params: register_json
      # Expect successful registration
      expect(response).to have_http_status(:ok)
      # Extract token from registration response
      JSON.parse(response.body)["user"]["api_tokens"].first["token"]
    else
      # Handle unexpected status codes
      raise "Unexpected response status: #{response.status}"
    end
  end
end
