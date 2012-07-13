require 'test_helper'

class SuggestionsControllerTest < ActionController::TestCase
  test "should get display" do
    get :display
    assert_response :success
  end

  test "should get block_db_slots" do
    get :block_db_slots
    assert_response :success
  end

end
