require 'test_helper'

class ContractControllerTest < ActionController::TestCase
  test "should get create" do
    get :create
    assert_response :success
  end

  test "should get renew" do
    get :renew
    assert_response :success
  end

  test "should get list" do
    get :list
    assert_response :success
  end

  test "should get view" do
    get :view
    assert_response :success
  end

  test "should get complete" do
    get :complete
    assert_response :success
  end

  test "should get cancel" do
    get :cancel
    assert_response :success
  end

end
