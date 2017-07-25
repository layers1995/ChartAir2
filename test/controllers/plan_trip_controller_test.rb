require 'test_helper'

class PlanTripControllerTest < ActionDispatch::IntegrationTest
  
  test "should get trip_details" do
    get plantrip_url
    assert_response :success
  end

  test "should get results" do
    get results_url
    assert_response :success
  end

end
