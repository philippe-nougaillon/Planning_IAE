require "test_helper"

class InvitsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @invit = invits(:one)
  end

  test "should get index" do
    get invits_url
    assert_response :success
  end

  test "should get new" do
    get new_invit_url
    assert_response :success
  end

  test "should create invit" do
    assert_difference('Invit.count') do
      post invits_url, params: { invit: { cour_id: @invit.cour_id, intervenant_id: @invit.intervenant_id, msg: @invit.msg, workflow_state: @invit.workflow_state } }
    end

    assert_redirected_to invit_url(Invit.last)
  end

  test "should show invit" do
    get invit_url(@invit)
    assert_response :success
  end

  test "should get edit" do
    get edit_invit_url(@invit)
    assert_response :success
  end

  test "should update invit" do
    patch invit_url(@invit), params: { invit: { cour_id: @invit.cour_id, intervenant_id: @invit.intervenant_id, msg: @invit.msg, workflow_state: @invit.workflow_state } }
    assert_redirected_to invit_url(@invit)
  end

  test "should destroy invit" do
    assert_difference('Invit.count', -1) do
      delete invit_url(@invit)
    end

    assert_redirected_to invits_url
  end
end
