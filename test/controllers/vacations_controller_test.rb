require "test_helper"

class VacationsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get vacations_index_url
    assert_response :success
  end
end
