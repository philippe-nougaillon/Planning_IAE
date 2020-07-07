require 'test_helper'

class EnvoiLogsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @envoi_log = envoi_logs(:one)
  end

  test "should get index" do
    get envoi_logs_url
    assert_response :success
  end

  test "should get new" do
    get new_envoi_log_url
    assert_response :success
  end

  test "should create envoi_log" do
    assert_difference('EnvoiLog.count') do
      post envoi_logs_url, params: { envoi_log: {  } }
    end

    assert_redirected_to envoi_log_url(EnvoiLog.last)
  end

  test "should show envoi_log" do
    get envoi_log_url(@envoi_log)
    assert_response :success
  end

  test "should get edit" do
    get edit_envoi_log_url(@envoi_log)
    assert_response :success
  end

  test "should update envoi_log" do
    patch envoi_log_url(@envoi_log), params: { envoi_log: {  } }
    assert_redirected_to envoi_log_url(@envoi_log)
  end

  test "should destroy envoi_log" do
    assert_difference('EnvoiLog.count', -1) do
      delete envoi_log_url(@envoi_log)
    end

    assert_redirected_to envoi_logs_url
  end
end
