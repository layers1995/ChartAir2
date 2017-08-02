require 'test_helper'

class UsersAirplanesControllerTest < ActionDispatch::IntegrationTest
  
  def setup
    @user = User.new(name: "Michael Hartl", email: "mhartl@example.com", password: "password", password_confirmation: "password")
    @user.save
    @airplane= Airplane.new(model: "172 skyhawk" , manufacturer: "cessna", engine_class: "single piston", weight:2500, height:10, wingspan:25, length:20)
    @airplane.save
  end
  
  test "shouldn't get profile, not logged in" do
    get login_path
    assert_response :success
  end
  
  test "should get profile" do
    post login_path, params: { session: { name: @user.name, password: 'password' } }
    get profile_path
    assert_response :success
  end
  
  test "user saves plane success" do
    post login_path, params: { session: { name: @user.name, password: 'password' } }
    get profile_path
    post profile_path, params: { user_airplane_params: { model: "172 skyhawk", manufacturer: "cessna" } }
    assert_response :success
  end
  
  test "display current plane" do
    post login_path, params: { session: { name: @user.name, password: 'password' } }
    get profile_path
    
    post profile_path, params: { user_airplane_params: { model: "172 skyhawk", manufacturer: "cessna" } }
    assert_response :success
    
    assert_template 'users_airplanes/profile'
    #check if there is an airplane shown
  end
  
  test "displays multiples of same airplane" do
    post login_path, params: { session: { name: @user.name, password: 'password' } }
    get profile_path
    
    post profile_path, params: { user_airplane_params: { model: "172 skyhawk", manufacturer: "cessna" } }
    assert_response :success
    
    assert_template 'users_airplanes/profile'
    #check if there is an airplane shown
    
    post profile_path, params: { user_airplane_params: { model: "172 skyhawk", manufacturer: "cessna" } }
    assert_response :success
    
    assert_template 'users_airplanes/profile'
    #check if there is two airplanes being shown
  end
  
  test "deletes airplane from airplane user table" do
    
  end
  
  test "deleted user also deletes entry in table" do
    
  end

end
