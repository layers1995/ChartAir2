require 'test_helper'

class FboPagesControllerTest < ActionDispatch::IntegrationTest
  test "should get fbo_profile" do
    get fbo_pages_fbo_profile_url
    assert_response :success
  end

  test "should get fbo_form" do
    get fbo_pages_fbo_form_url
    assert_response :success
  end

end
