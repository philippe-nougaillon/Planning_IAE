require "test_helper"

class ResponsabilitesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @responsabilite = responsabilites(:one)
  end

  test "should get index" do
    get responsabilites_url
    assert_response :success
  end

  test "should get new" do
    get new_responsabilite_url
    assert_response :success
  end

  test "should create responsabilite" do
    assert_difference("Responsabilite.count") do
      post responsabilites_url, params: { responsabilite: {} }
    end

    assert_redirected_to responsabilite_url(Responsabilite.last)
  end

  test "should show responsabilite" do
    get responsabilite_url(@responsabilite)
    assert_response :success
  end

  test "should get edit" do
    get edit_responsabilite_url(@responsabilite)
    assert_response :success
  end

  test "should update responsabilite" do
    patch responsabilite_url(@responsabilite), params: { responsabilite: {} }
    assert_redirected_to responsabilite_url(@responsabilite)
  end

  test "should destroy responsabilite" do
    assert_difference("Responsabilite.count", -1) do
      delete responsabilite_url(@responsabilite)
    end

    assert_redirected_to responsabilites_url
  end
end
