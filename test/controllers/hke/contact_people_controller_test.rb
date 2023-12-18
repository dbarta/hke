require "test_helper"

module Hke
  class ContactPeopleControllerTest < ActionDispatch::IntegrationTest
    include Engine.routes.url_helpers

    setup do
      @contact_person = hke_contact_people(:one)
    end

    test "should get index" do
      get contact_people_url
      assert_response :success
    end

    test "should get new" do
      get new_contact_person_url
      assert_response :success
    end

    test "should create contact_person" do
      assert_difference("ContactPerson.count") do
        post contact_people_url, params: { contact_person: { email: @contact_person.email, first_name: @contact_person.first_name, gender: @contact_person.gender, last_name: @contact_person.last_name, phone: @contact_person.phone } }
      end

      assert_redirected_to contact_person_url(ContactPerson.last)
    end

    test "should show contact_person" do
      get contact_person_url(@contact_person)
      assert_response :success
    end

    test "should get edit" do
      get edit_contact_person_url(@contact_person)
      assert_response :success
    end

    test "should update contact_person" do
      patch contact_person_url(@contact_person), params: { contact_person: { email: @contact_person.email, first_name: @contact_person.first_name, gender: @contact_person.gender, last_name: @contact_person.last_name, phone: @contact_person.phone } }
      assert_redirected_to contact_person_url(@contact_person)
    end

    test "should destroy contact_person" do
      assert_difference("ContactPerson.count", -1) do
        delete contact_person_url(@contact_person)
      end

      assert_redirected_to contact_people_url
    end
  end
end
