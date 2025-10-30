require "test_helper"

class EdusignLogsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @edusign_log = edusign_logs(:one)
  end

  test "should get index" do
    get edusign_logs_url
    assert_response :success
  end

  test "should get new" do
    get new_edusign_log_url
    assert_response :success
  end

  test "should create edusign_log" do
    assert_difference("EdusignLog.count") do
      post edusign_logs_url, params: { edusign_log: { messages: @edusign_log.messages, statut: @edusign_log.statut, type: @edusign_log.type, user_id: @edusign_log.user_id } }
    end

    assert_redirected_to edusign_log_url(EdusignLog.last)
  end

  test "should show edusign_log" do
    get edusign_log_url(@edusign_log)
    assert_response :success
  end

  test "should get edit" do
    get edit_edusign_log_url(@edusign_log)
    assert_response :success
  end

  test "should update edusign_log" do
    patch edusign_log_url(@edusign_log), params: { edusign_log: { messages: @edusign_log.messages, statut: @edusign_log.statut, type: @edusign_log.type, user_id: @edusign_log.user_id } }
    assert_redirected_to edusign_log_url(@edusign_log)
  end

  test "should destroy edusign_log" do
    assert_difference("EdusignLog.count", -1) do
      delete edusign_log_url(@edusign_log)
    end

    assert_redirected_to edusign_logs_url
  end
end
