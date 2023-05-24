require "test_helper"

class PagesControllerTest < ActionDispatch::IntegrationTest
  test "should get mentions_légales" do
    get pages_mentions_légales_url
    assert_response :success
  end
end
