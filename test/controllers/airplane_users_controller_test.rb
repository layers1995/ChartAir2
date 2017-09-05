require 'test_helper'

class AirplaneUsersControllerTest < ActionDispatch::IntegrationTest
  test "should get add_plane" do
    get airplane_users_add_plane_url
    assert_response :success
  end

  test "should get profile" do
    get airplane_users_profile_url
    assert_response :success
  end

end
