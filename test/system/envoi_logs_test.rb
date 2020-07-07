require "application_system_test_case"

class EnvoiLogsTest < ApplicationSystemTestCase
  setup do
    @envoi_log = envoi_logs(:one)
  end

  test "visiting the index" do
    visit envoi_logs_url
    assert_selector "h1", text: "Envoi Logs"
  end

  test "creating a Envoi log" do
    visit envoi_logs_url
    click_on "New Envoi Log"

    click_on "Create Envoi log"

    assert_text "Envoi log was successfully created"
    click_on "Back"
  end

  test "updating a Envoi log" do
    visit envoi_logs_url
    click_on "Edit", match: :first

    click_on "Update Envoi log"

    assert_text "Envoi log was successfully updated"
    click_on "Back"
  end

  test "destroying a Envoi log" do
    visit envoi_logs_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Envoi log was successfully destroyed"
  end
end
