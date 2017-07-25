class UsersController < ApplicationController
  
  def new
    @user = User.new
  end
  
  def profile
    #get info about current user and show it
  end
  
  def create
    @user = User.new(user_params)
    
    if @user.save
      flash[:success] = "Thank you for joining ChartAir"
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
