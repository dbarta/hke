require "application_system_test_case"

module Hke
  class ContactPeopleTest < ApplicationSystemTestCase
    setup do
      @contact_person = hke_contact_people(:one)
    end

    test "visiting the index" do
      visit contact_people_url
      assert_selector "h1", text: "Contact people"
    end

    test "should create contact person" do
      visit contact_people_url
      click_on "New contact person"

      fill_in "Email", with: @contact_person.email
      fill_in "First name", with: @contact_person.first_name
      fill_in "Gender", with: @contact_person.gender
      fill_in "Last name", with: @contact_person.last_name
      fill_in "Phone", with: @contact_person.phone
      click_on "Create Contact person"

      assert_text "Contact person was successfully created"
      click_on "Back"
    end

    test "should update Contact person" do
      visit contact_person_url(@contact_person)
      click_on "Edit this contact person", match: :first

      fill_in "Email", with: @contact_person.email
      fill_in "First name", with: @contact_person.first_name
      fill_in "Gender", with: @contact_person.gender
      fill_in "Last name", with: @contact_person.last_name
      fill_in "Phone", with: @contact_person.phone
      click_on "Update Contact person"

      assert_text "Contact person was successfully updated"
      click_on "Back"
    end

    test "should destroy Contact person" do
      visit contact_person_url(@contact_person)
      click_on "Destroy this contact person", match: :first

      assert_text "Contact person was successfully destroyed"
    end
  end
end
