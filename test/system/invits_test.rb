require "application_system_test_case"

class InvitsTest < ApplicationSystemTestCase
  setup do
    @invit = invits(:one)
  end

  test "visiting the index" do
    visit invits_url
    assert_selector "h1", text: "Invits"
  end

  test "creating a Invit" do
    visit invits_url
    click_on "New Invit"

    fill_in "Cour", with: @invit.cour_id
    fill_in "Intervenant", with: @invit.intervenant_id
    fill_in "Msg", with: @invit.msg
    fill_in "Workflow state", with: @invit.workflow_state
    click_on "Create Invit"

    assert_text "Invit was successfully created"
    click_on "Back"
  end

  test "updating a Invit" do
    visit invits_url
    click_on "Edit", match: :first

    fill_in "Cour", with: @invit.cour_id
    fill_in "Intervenant", with: @invit.intervenant_id
    fill_in "Msg", with: @invit.msg
    fill_in "Workflow state", with: @invit.workflow_state
    click_on "Update Invit"

    assert_text "Invit was successfully updated"
    click_on "Back"
  end

  test "destroying a Invit" do
    visit invits_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Invit was successfully destroyed"
  end
end
