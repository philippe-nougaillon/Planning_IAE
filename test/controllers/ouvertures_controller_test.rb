require "test_helper"

class OuverturesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @ouverture = ouvertures(:one)
  end

  test "should get index" do
    get ouvertures_url
    assert_response :success
  end

  test "should get new" do
    get new_ouverture_url
    assert_response :success
  end

  test "should create ouverture" do
    assert_difference('Ouverture.count') do
      post ouvertures_url, params: { ouverture: { bloc: @ouverture.bloc, début: @ouverture.début, fin: @ouverture.fin, jour: @ouverture.jour } }
    end

    assert_redirected_to ouverture_url(Ouverture.last)
  end

  test "should show ouverture" do
    get ouverture_url(@ouverture)
    assert_response :success
  end

  test "should get edit" do
    get edit_ouverture_url(@ouverture)
    assert_response :success
  end

  test "should update ouverture" do
    patch ouverture_url(@ouverture), params: { ouverture: { bloc: @ouverture.bloc, début: @ouverture.début, fin: @ouverture.fin, jour: @ouverture.jour } }
    assert_redirected_to ouverture_url(@ouverture)
  end

  test "should destroy ouverture" do
    assert_difference('Ouverture.count', -1) do
      delete ouverture_url(@ouverture)
    end

    assert_redirected_to ouvertures_url
  end
end
