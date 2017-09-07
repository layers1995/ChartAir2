require 'test_helper'

class PlanTripControllerTest < ActionDispatch::IntegrationTest
  
  def setup
    @user = User.new(name: "Michael Hartl", email: "mhartl@example.com", password: "password", password_confirmation: "password")
    @user.save
    @airplane= Airplane.new(model: "172 skyhawk" , manufacturer: "cessna", engine_class: "single piston", weight:2500, height:10, wingspan:25, length:20)
    @airplane.save
    @city= City.new(name: "supercity" , state: "state" ,latitude:100 , longitude: 100)
    @city.save
  end
  
  test "shouldn't get plantrip if not logged in" do
    get plantrip_path
    follow_redirect!
    assert_response :success
  end
  
  test "should get plantrip if logged in and has airplane" do
    post login_path, params: { session: { name: @user.name, password: 'password' } }
    AirplaneUser.create(:airplane_id => @airplane.id, :user_id => User.find_by(:id => @user.id).id, :tailnumber => "tailie")
    get plantrip_path
    assert_response :success
  end
  
  test "redirect to profile if there is no airplane" do
    post login_path, params: { session: { name: @user.name, password: 'password' } }
    get plantrip_path
    follow_redirect!
    assert_template 'airplane_users/profile'
  end
  
  test "redirect to trip details when information is invalid" do
    post login_path, params: { session: { name: @user.name, password: 'password' } }
    AirplaneUser.create(:airplane_id => Airplane.first.id, :user_id => User.find_by(:id => @user.id).id, :tailnumber => "tailie")
    get plantrip_path
    assert_response :success
    assert_template 'plan_trip/trip_details'
    
    assert AirplaneUser.first.tailnumber!=nil
    post plantrip_path, params: {city: "supercity" , distance: -10, :airplane => AirplaneUser.first.tailnumber}
    follow_redirect!
    assert_template 'plan_trip/trip_details'
  end
  
  test "redirect to results when information is valid" do
    post login_path, params: { session: { name: @user.name, password: 'password' } }
    AirplaneUser.create(:airplane_id => Airplane.first.id, :user_id => User.find_by(:id => @user.id).id, :tailnumber => "tailie")
    get plantrip_path
    assert_response :success
    assert_template 'plan_trip/trip_details'
    
    assert AirplaneUser.first.tailnumber!=nil
    arrival_date = DateTime.new(2020, 07, 11, 20, 10, 0)
    depart_date= DateTime.new(2020, 07, 15, 20, 10, 0)
    post plantrip_path, params: {city: "supercity", distance: 50, :airplane => AirplaneUser.first.tailnumber, :arrival_time => arrival_date, :depart_time => depart_date}
    assert_template 'plan_trip/results'
  end

end
