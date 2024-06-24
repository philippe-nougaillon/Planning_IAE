require "test_helper"

class VacationActivitesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @vacation_activite = vacation_activites(:one)
  end

  test "should get index" do
    get vacation_activites_url
    assert_response :success
  end

  test "should get new" do
    get new_vacation_activite_url
    assert_response :success
  end

  test "should create vacation_activite" do
    assert_difference("VacationActivite.count") do
      post vacation_activites_url, params: { vacation_activite: { nature: @vacation_activite.nature, nom: @vacation_activite.nom } }
    end

    assert_redirected_to vacation_activite_url(VacationActivite.last)
  end

  test "should show vacation_activite" do
    get vacation_activite_url(@vacation_activite)
    assert_response :success
  end

  test "should get edit" do
    get edit_vacation_activite_url(@vacation_activite)
    assert_response :success
  end

  test "should update vacation_activite" do
    patch vacation_activite_url(@vacation_activite), params: { vacation_activite: { nature: @vacation_activite.nature, nom: @vacation_activite.nom } }
    assert_redirected_to vacation_activite_url(@vacation_activite)
  end

  test "should destroy vacation_activite" do
    assert_difference("VacationActivite.count", -1) do
      delete vacation_activite_url(@vacation_activite)
    end

    assert_redirected_to vacation_activites_url
  end
end
