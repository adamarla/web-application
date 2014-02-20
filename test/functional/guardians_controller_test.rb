require 'test_helper'

class GuardiansControllerTest < ActionController::TestCase
  test "should get create" do
    get :create
    assert_response :success
  end

  test "should get show" do
    get :show
    assert_response :success
  end

  test "should get add_student" do
    get :add_student
    assert_response :success
  end

  test "should get buy_credit" do
    get :buy_credit
    assert_response :success
  end

  test "should get students" do
    get :students
    assert_response :success
  end

end
