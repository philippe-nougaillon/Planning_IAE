require "test_helper"

class SujetsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @sujet = sujets(:one)
  end

  test "should get index" do
    get sujets_url
    assert_response :success
  end

  test "should get new" do
    get new_sujet_url
    assert_response :success
  end

  test "should create sujet" do
    assert_difference("Sujet.count") do
      post sujets_url, params: { sujet: { cour_id: @sujet.cour_id, mail_log_id: @sujet.mail_log_id, slug: @sujet.slug, workflow_state: @sujet.workflow_state } }
    end

    assert_redirected_to sujet_url(Sujet.last)
  end

  test "should show sujet" do
    get sujet_url(@sujet)
    assert_response :success
  end

  test "should get edit" do
    get edit_sujet_url(@sujet)
    assert_response :success
  end

  test "should update sujet" do
    patch sujet_url(@sujet), params: { sujet: { cour_id: @sujet.cour_id, mail_log_id: @sujet.mail_log_id, slug: @sujet.slug, workflow_state: @sujet.workflow_state } }
    assert_redirected_to sujet_url(@sujet)
  end

  test "should destroy sujet" do
    assert_difference("Sujet.count", -1) do
      delete sujet_url(@sujet)
    end

    assert_redirected_to sujets_url
  end
end
