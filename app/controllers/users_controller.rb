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
  
  def create
    @user = User.new(user_params)
    
    if @user.save
      flash[:success] = "Thank you for joining ChartAir"
      log_in @user
      redirect_to profile_url(@user)
    else
      render 'new'
    end
    
  end
  
  private

    def user_params
      params.require(:user).permit(:name, :email, :password, :password_confirmation)
    end
    
end
