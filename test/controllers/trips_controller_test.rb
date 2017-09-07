require 'test_helper'

class TripsControllerTest < ActionDispatch::IntegrationTest
  
  def setup
    @user = User.new(name: "Michael Hartl", email: "mhartl@example.com", password: "password", password_confirmation: "password")
    @user.save
  end
  
  test "should get trips_path" do
    get trips_path
    assert_response :success
  end

  test "should get resolve trip" do
    get resolve_trip_path
    assert_response :success
  end
  
  test "displays trips" do 
    post login_path, params: { session: { name: @user.name, password: 'password' } }
    #create a new trip with issue
    @trip= Trip.new(user_id: @user.id, trip_status: "issue", arrival_time: Time.now, airport_id: Airport.first.id)
    @trip.save
    #go to issue resolution page
    get trips_path
    
    var=0
    
    assert_select "tr" do |elements|
      var+=1
    end
    
    print var
    assert var>0
  end
  
  

end
