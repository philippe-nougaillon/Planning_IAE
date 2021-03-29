require "test_helper"

class DossiersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @dossier = dossiers(:one)
  end

  test "should get index" do
    get dossiers_url
    assert_response :success
  end

  test "should get new" do
    get new_dossier_url
    assert_response :success
  end

  test "should create dossier" do
    assert_difference('Dossier.count') do
      post dossiers_url, params: { dossier: { intervenant_id: @dossier.intervenant_id, période: @dossier.période, workflow_state: @dossier.workflow_state } }
    end

    assert_redirected_to dossier_url(Dossier.last)
  end

  test "should show dossier" do
    get dossier_url(@dossier)
    assert_response :success
  end

  test "should get edit" do
    get edit_dossier_url(@dossier)
    assert_response :success
  end

  test "should update dossier" do
    patch dossier_url(@dossier), params: { dossier: { intervenant_id: @dossier.intervenant_id, période: @dossier.période, workflow_state: @dossier.workflow_state } }
    assert_redirected_to dossier_url(@dossier)
  end

  test "should destroy dossier" do
    assert_difference('Dossier.count', -1) do
      delete dossier_url(@dossier)
    end

    assert_redirected_to dossiers_url
  end
end
