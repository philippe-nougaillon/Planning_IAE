require "application_system_test_case"

class SallesTest < ApplicationSystemTestCase

  # setup do
  #   login_user
  # end

  test "visiter l'index" do
    visit occupation_salles_url
  
    assert_selector "h3", text: "Occupation des salles"
  end

  # test "visiter l'index" do
  #   visit occupation_salles_url
  
  #   assert_selector "h3", text: "Occupation des salles"
  # end

end
