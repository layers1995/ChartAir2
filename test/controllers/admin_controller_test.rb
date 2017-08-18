require 'test_helper'

class AdminControllerTest < ActionDispatch::IntegrationTest
  
  def setup
    @user = User.new(name: "OliviaCanEat", email: "mhartl@example.com", password: "password", password_confirmation: "password")
    @user.save
  end
  
  test "should get admin_login" do
    get admin_login_path
    assert_response :success
  end

  test "should get admin_main if logged in" do
    post login_path, params: { session: { name: @user.name, password: 'password' } }
    get admin_main_path
    assert :success
    assert_template 'admin/admin_main'
  end
  
  test "should redirect to login if admin not logged in" do
    get admin_main_path
    follow_redirect!
    assert_template 'admin/admin_login'
  end
  
  test "should update status of trip" do
    
  end
  
end
