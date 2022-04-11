require "application_system_test_case"

class OuverturesTest < ApplicationSystemTestCase
  setup do
    @ouverture = ouvertures(:one)
  end

  test "visiting the index" do
    visit ouvertures_url
    assert_selector "h1", text: "Ouvertures"
  end

  test "creating a Ouverture" do
    visit ouvertures_url
    click_on "New Ouverture"

    fill_in "Bloc", with: @ouverture.bloc
    fill_in "Début", with: @ouverture.début
    fill_in "Fin", with: @ouverture.fin
    fill_in "Jour", with: @ouverture.jour
    click_on "Create Ouverture"

    assert_text "Ouverture was successfully created"
    click_on "Back"
  end

  test "updating a Ouverture" do
    visit ouvertures_url
    click_on "Edit", match: :first

    fill_in "Bloc", with: @ouverture.bloc
    fill_in "Début", with: @ouverture.début
    fill_in "Fin", with: @ouverture.fin
    fill_in "Jour", with: @ouverture.jour
    click_on "Update Ouverture"

    assert_text "Ouverture was successfully updated"
    click_on "Back"
  end

  test "destroying a Ouverture" do
    visit ouvertures_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Ouverture was successfully destroyed"
  end
end
