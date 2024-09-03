require "rails_helper"
require "json"
require "rack/utils"

RSpec.describe "DeceasedPersons API", type: :request do
  include TestApiHelper
  include RequestJson

  let(:base_url) { "http://localhost:3000/api/v1" }
  let(:auth_url) { "#{base_url}/auth" }
  let(:register_url) { "#{base_url}/users" }
  let(:hke_url) { "http://localhost:3000/hke/api/v1" }
  let(:create_deceased_person_url) { "#{hke_url}/deceased_people" }
  let(:token) { ensure_user_and_get_token }

  describe "DeceasedPerson creation with and without contacts" do
    puts "DeceasedPerson creation with and without contacts"
    it "Creates a deceased person" do
      create_deceased_person deceased_person_json, "Create deceased person, NO contacts"
      expect(response).to have_http_status(:created)
      dp_no_contact_id = JSON.parse(response.body)["id"]
      api_logger.info "DP0 id: #{dp_no_contact_id}"

      create_deceased_person deceased_person_json(include_relation: true), "Create deceased person, ONE contact, NO address"
      expect(response).to have_http_status(:created)
      dp_1_contact_no_address_id = JSON.parse(response.body)["id"]
      api_logger.info "DP1 id: #{dp_1_contact_no_address_id}"

      create_deceased_person deceased_person_json(include_relation: true,
        include_contact_address: true), "Create deceased person, ONE contact, WITH address"
      expect(response).to have_http_status(:created)
      dp_1_contact_1_address_id = JSON.parse(response.body)["id"]
      api_logger.info "DP2 id: #{dp_1_contact_1_address_id}"

      deceased_person_id = JSON.parse(response.body)["id"]

      # Update the deceased person to add one contact person
      updated_params = {
        id: deceased_person_id,
        first_name: "Updated Name",
        relations_attributes: [
          relation_json
        ]
      }
      put "#{hke_url}/deceased_people/#{deceased_person_id}", params: {deceased_person: updated_params}, headers: {Authorization: "Bearer #{token}"}
      # expect(response).to have_http_status(:ok)
      expect(response).to have_http_status(:ok), "Expected HTTP status '200' but got '#{response.status}'. Response body: #{response.body}"

      # Show the deceased person
      get "#{hke_url}/deceased_people/#{deceased_person_id}", headers: {Authorization: "Bearer #{token}"}
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)["first_name"]).to eq("Updated Name")

      # Delete the deceased person
      delete "#{hke_url}/deceased_people/#{deceased_person_id}", headers: {Authorization: "Bearer #{token}"}
      expect(response).to have_http_status(:no_content)
    end
  end
end
