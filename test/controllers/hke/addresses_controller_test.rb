require "test_helper"

module Hke
  class AddressesControllerTest < ActionDispatch::IntegrationTest
    include Engine.routes.url_helpers

    setup do
      @address = hke_addresses(:one)
    end

    test "should get index" do
      get addresses_url
      assert_response :success
    end

    test "should get new" do
      get new_address_url
      assert_response :success
    end

    test "should create address" do
      assert_difference("Address.count") do
        post addresses_url, params: { address: { addressable_id: @address.addressable_id, city: @address.city, country: @address.country, description: @address.description, name: @address.name, region: @address.region, street: @address.street, zipcode: @address.zipcode } }
      end

      assert_redirected_to address_url(Address.last)
    end

    test "should show address" do
      get address_url(@address)
      assert_response :success
    end

    test "should get edit" do
      get edit_address_url(@address)
      assert_response :success
    end

    test "should update address" do
      patch address_url(@address), params: { address: { addressable_id: @address.addressable_id, city: @address.city, country: @address.country, description: @address.description, name: @address.name, region: @address.region, street: @address.street, zipcode: @address.zipcode } }
      assert_redirected_to address_url(@address)
    end

    test "should destroy address" do
      assert_difference("Address.count", -1) do
        delete address_url(@address)
      end

      assert_redirected_to addresses_url
    end
  end
end
