require 'test_helper'

class UsersLoginTest < ActionDispatch::IntegrationTest
    
  def setup
    get new_user_path
    post create_path, params: { user_param: { name: "catcatdog", password: 'password', betakey: "FlyInTheClouds", password_confirmation: 'password', email: 'cat@cat.com', email_confirm: 'cat@cat.com', confirm_user_agreement: "1" } }
    assert_template 'airplane_users/profile'
  end

  test "login with invalid information" do
    get login_path
    assert_template 'sessions/new'
    post login_path, params: { session: { name: "", password: "" } }
    assert_template 'sessions/new'
    assert_not flash.empty?
    get root_path
    assert flash.empty?
  end
  
  
  test "login with valid information" do
    assert User.find_by(:name => @user.name)!= nil
    get login_path
    post login_path, params: { session: { name: "catcatdog", password: 'password' } }
    assert is_logged_in?
    assert_redirected_to '/profile'
    follow_redirect!
    assert_template 'users_airplanes/profile'
  end
  
  
  test "login with valid information followed by logout" do
    #login  
    get login_path
    post login_path, params: { session: { name: "catcatdog", password: 'password' } }
    assert is_logged_in?
    assert_redirected_to '/profile'
    follow_redirect!
    assert_template 'users_airplanes/profile'
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