require "test_helper"

class DossierEtudiantsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @dossier_etudiant = dossier_etudiants(:one)
  end

  test "should get index" do
    get dossier_etudiants_url
    assert_response :success
  end

  test "should get new" do
    get new_dossier_etudiant_url
    assert_response :success
  end

  test "should create dossier_etudiant" do
    assert_difference("DossierEtudiant.count") do
      post dossier_etudiants_url, params: { dossier_etudiant: { etudiant_id: @dossier_etudiant.etudiant_id, mode_payement: @dossier_etudiant.mode_payement } }
    end

    assert_redirected_to dossier_etudiant_url(DossierEtudiant.last)
  end

  test "should show dossier_etudiant" do
    get dossier_etudiant_url(@dossier_etudiant)
    assert_response :success
  end

  test "should get edit" do
    get edit_dossier_etudiant_url(@dossier_etudiant)
    assert_response :success
  end

  test "should update dossier_etudiant" do
    patch dossier_etudiant_url(@dossier_etudiant), params: { dossier_etudiant: { etudiant_id: @dossier_etudiant.etudiant_id, mode_payement: @dossier_etudiant.mode_payement } }
    assert_redirected_to dossier_etudiant_url(@dossier_etudiant)
  end

  test "should destroy dossier_etudiant" do
    assert_difference("DossierEtudiant.count", -1) do
      delete dossier_etudiant_url(@dossier_etudiant)
    end

    assert_redirected_to dossier_etudiants_url
  end
end
