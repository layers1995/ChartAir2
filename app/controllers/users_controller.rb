class UsersController < ApplicationController
  
  def new
    @user = User.new
  end
  
  def profile
    if not logged_in?
      redirect_to login_path
    end
    @user= current_user
  end
  
  def terms
  end
  
  def create
    
    if params[:user][:betakey]==="FlyInTheClouds" && params[:user][:email]===params[:user][:email_confirm] && params[:user][:confirm_user_agreement]=="1"
      
      @user = User.new(:name => params[:user][:name], :password => params[:user][:password], :password_confirmation => params[:user][:password_confirmation], :email => params[:user][:email])
      
      if @user.save
        flash[:success] = "Thank you for joining ChartAir"
        UserMailer.welcome_email(@user).deliver_now
        log_in @user
        redirect_to home_path
      else
        @user = User.new
        render 'new'
      end
      
    else
      @user = User.new
       render 'new'
    end
    
  end
  
  private

    def user_params
      params.require(:user).permit(:name, :email, :email_confirm, :betakey, :password, :password_confirmation)
    end
    
end
