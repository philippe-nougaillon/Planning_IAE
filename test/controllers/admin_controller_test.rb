require "test_helper"

class AdminControllerTest < ActionDispatch::IntegrationTest
  test "should get create_new_user" do
    get admin_create_new_user_url
    assert_response :success
  end
end
