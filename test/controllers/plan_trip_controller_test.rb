require 'test_helper'

class PlanTripControllerTest < ActionDispatch::IntegrationTest
  
  def setup
    @user = User.new(name: "Michael Hartl", email: "mhartl@example.com", password: "password", password_confirmation: "password")
    @user.save
  end
  
  test "should get results" do
    get results_path
    assert_response :success
  end
  
  test "shouldn't get plantrip if not logged in" do
    get home_path
    assert_response :success
  end
  
  test "should get plantrip if logged in" do
    post login_path, params: { session: { name: @user.name, password: 'password' } }
    get plantrip_path
    assert_response :success
  end

end
