require 'test_helper'

class QuestionControllerTest < ActionController::TestCase
  test "should get insert_new" do
    get :insert_new
    assert_response :success
  end

end
