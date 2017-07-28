require 'test_helper'

class UsersLoginTest < ActionDispatch::IntegrationTest
    
  def setup
    @user = User.new(name: "Michael Hartl", email: "mhartl@example.com", password: "password", password_confirmation: "password")
    @user.save
  end

  test "login with invalid information" do
    get login_path
    assert_template 'sessions/new'
    post login_path, params: { session: { email: "", password: "" } }
    assert_template 'sessions/new'
    assert_not flash.empty?
    get root_path
    assert flash.empty? #ERROR HERE! Flash not disappearing
  end
  
  
  test "login with valid information" do
    get login_path
    post login_path, params: { session: { name: @user.name, password: 'password' } }
    assert_redirected_to '/profile'
    follow_redirect!
    assert_template 'users/profile'
  end
  
  
  test "login with valid information followed by logout" do
      
    #login  
    get login_path
    post login_path, params: { session: { name: @user.name, password: 'password' } }
    assert is_logged_in?
    assert_redirected_to '/profile'
    follow_redirect!
    assert_template 'users/profile'
    assert_select "a[href=?]", login_path, count: 0
    assert_select "a[href=?]", logout_path
    
    #logout
    delete logout_path
    assert_not is_logged_in?
    assert_redirected_to root_url
    follow_redirect!
    assert_select "a[href=?]", logout_path, count: 0
    
  end
  
end