require "test_helper"

class JustificatifsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @justificatif = justificatifs(:one)
  end

  test "should get index" do
    get justificatifs_url
    assert_response :success
  end

  test "should get new" do
    get new_justificatif_url
    assert_response :success
  end

  test "should create justificatif" do
    assert_difference("Justificatif.count") do
      post justificatifs_url, params: { justificatif: { accepte_le: @justificatif.accepte_le, commentaires: @justificatif.commentaires, debut: @justificatif.debut, edusign_created_at: @justificatif.edusign_created_at, edusign_id: @justificatif.edusign_id, etudiant_id: @justificatif.etudiant_id, file_url: @justificatif.file_url, fin: @justificatif.fin, nom: @justificatif.nom } }
    end

    assert_redirected_to justificatif_url(Justificatif.last)
  end

  test "should show justificatif" do
    get justificatif_url(@justificatif)
    assert_response :success
  end

  test "should get edit" do
    get edit_justificatif_url(@justificatif)
    assert_response :success
  end

  test "should update justificatif" do
    patch justificatif_url(@justificatif), params: { justificatif: { accepte_le: @justificatif.accepte_le, commentaires: @justificatif.commentaires, debut: @justificatif.debut, edusign_created_at: @justificatif.edusign_created_at, edusign_id: @justificatif.edusign_id, etudiant_id: @justificatif.etudiant_id, file_url: @justificatif.file_url, fin: @justificatif.fin, nom: @justificatif.nom } }
    assert_redirected_to justificatif_url(@justificatif)
  end

  test "should destroy justificatif" do
    assert_difference("Justificatif.count", -1) do
      delete justificatif_url(@justificatif)
    end

    assert_redirected_to justificatifs_url
  end
end
