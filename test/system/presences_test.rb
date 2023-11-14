require "application_system_test_case"

class PresencesTest < ApplicationSystemTestCase
  setup do
    @presence = presences(:one)
  end

  test "visiting the index" do
    visit presences_url
    assert_selector "h1", text: "Presences"
  end

  test "creating a Presence" do
    visit presences_url
    click_on "New Presence"

    fill_in "Cour", with: @presence.cour_id
    fill_in "Signature", with: @presence.signature
    fill_in "User", with: @presence.user_id
    click_on "Create Presence"

    assert_text "Presence was successfully created"
    click_on "Back"
  end

  test "updating a Presence" do
    visit presences_url
    click_on "Edit", match: :first

    fill_in "Cour", with: @presence.cour_id
    fill_in "Signature", with: @presence.signature
    fill_in "User", with: @presence.user_id
    click_on "Update Presence"

    assert_text "Presence was successfully updated"
    click_on "Back"
  end

  test "destroying a Presence" do
    visit presences_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Presence was successfully destroyed"
  end
end
