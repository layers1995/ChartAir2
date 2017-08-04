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
    assert_response :success
    post profile_path, params: { user_airplane_params: {tailnumber: "tailie", model: "172 skyhawk", manufacturer: "cessna" } }
    follow_redirect!
    assert_response :success
  end
  
  test "multiples of same airplane saved" do
    post login_path, params: { session: { name: @user.name, password: 'password' } }
    get profile_path
    assert_response :success
    AirplaneUser.create(:airplane_id => Airplane.first.id, :user_id => User.first.id, :tailnumber => "tailie")
    assert_response :success
    
    assert_template 'users_airplanes/profile'
    
    AirplaneUser.create(:airplane_id => Airplane.first.id, :user_id => User.first.id, :tailnumber => "tailie2")
    assert_response :success
    
    assert AirplaneUser.all.length==2
   
  end
  
  test "deletes row from airplane user table" do
    #creates airplane
    post login_path, params: { session: { name: @user.name, password: 'password' } }
    get profile_path
    assert_response :success
    AirplaneUser.create(:airplane_id => Airplane.first.id, :user_id => User.first.id, :tailnumber => "tail123")
    assert_response :success
    
    #deletes airplane
    AirplaneUser.find_by(:tailnumber => "tail123").destroy
    assert_response :success
  end
  
  test "delete airplane user rows if user deleted" do
    assert false
  end

end
