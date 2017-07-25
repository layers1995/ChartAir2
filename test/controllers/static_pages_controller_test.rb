require 'test_helper'

class StaticPagesControllerTest < ActionDispatch::IntegrationTest
  
  test "should get home" do
    get home_url
    assert_response :success
  end

  test "should get help" do
    get help_url
    assert_response :success
  end

  test "should get feedback" do
    get feedback_url
    assert_response :success
  end

  test "should get about_us" do
    get about_us_url
    assert_response :success
  end

end
