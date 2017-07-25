require 'test_helper'

class UserControllerTest < ActionDispatch::IntegrationTest
  
  test "should get new" do
    get new_user_url
    assert_response :success
  end
  
  test "should get profile" do
    get profile_url
    assert_response :success
  end

end
