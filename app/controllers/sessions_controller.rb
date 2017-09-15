class SessionsController < ApplicationController
  
  def new
    if logged_in?
      redirect_to profile_url
    end
  end
  
  def create
    user = User.find_by(name: params[:session][:name])
    
    if user && user.authenticate(params[:session][:password])
      log_in user
      loginInfo=Login.new(:user_id => current_user.id)
      loginInfo.save
      redirect_to profile_url
    else
      flash.now[:danger] = 'Invalid email/password combination'
      render 'new'
    end
  end
  
  def destroy
    log_out if logged_in?
    redirect_to root_url
  end
  
end
