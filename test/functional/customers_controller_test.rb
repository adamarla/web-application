require 'test_helper'

class CustomersControllerTest < ActionController::TestCase
  test "should get show" do
    get :show
    assert_response :success
  end

  test "should get list" do
    get :list
    assert_response :success
  end

  test "should get activity" do
    get :activity
    assert_response :success
  end

  test "should get transactions" do
    get :transactions
    assert_response :success
  end

end
