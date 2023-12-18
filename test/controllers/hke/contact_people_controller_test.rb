require "test_helper"

module Hke
  class ContactPeopleControllerTest < ActionDispatch::IntegrationTest
    include Engine.routes.url_helpers

    test "should get index" do
      get contact_people_index_url
      assert_response :success
    end

    test "should get edit" do
      get contact_people_edit_url
      assert_response :success
    end

    test "should get show" do
      get contact_people_show_url
      assert_response :success
    end
  end
end
