require "application_system_test_case"

class DossiersTest < ApplicationSystemTestCase
  setup do
    @dossier = dossiers(:one)
  end

  test "visiting the index" do
    visit dossiers_url
    assert_selector "h1", text: "Dossiers"
  end

  test "creating a Dossier" do
    visit dossiers_url
    click_on "New Dossier"

    fill_in "Intervenant", with: @dossier.intervenant_id
    fill_in "Période", with: @dossier.période
    fill_in "Workflow state", with: @dossier.workflow_state
    click_on "Create Dossier"

    assert_text "Dossier was successfully created"
    click_on "Back"
  end

  test "updating a Dossier" do
    visit dossiers_url
    click_on "Edit", match: :first

    fill_in "Intervenant", with: @dossier.intervenant_id
    fill_in "Période", with: @dossier.période
    fill_in "Workflow state", with: @dossier.workflow_state
    click_on "Update Dossier"

    assert_text "Dossier was successfully updated"
    click_on "Back"
  end

  test "destroying a Dossier" do
    visit dossiers_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Dossier was successfully destroyed"
  end
end
