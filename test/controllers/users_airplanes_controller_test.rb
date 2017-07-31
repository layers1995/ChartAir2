require 'test_helper'

class UsersAirplanesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get users_airplanes_index_url
    assert_response :success
  end

end
