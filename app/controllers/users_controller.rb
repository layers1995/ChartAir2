class UsersController < ApplicationController
  
  def index
    redirect_to 'new'
  end
  
  def new
    @user = User.new
  end
  
  def terms
  end
  
  def create
    
      @user = User.new(user_params)
      
      if @user.save
        #flash[:success] = "Thank you for joining ChartAir"
        UserMailer.welcome_email(@user).deliver_now
        log_in @user
        redirect_to "static_pages#home"
      else
        render 'new'
      end
    
  end
  
  private

    def user_params
      params.require(:user).permit(:name, :email, :email_confirm, :betakey, :password, :password_confirmation, :confirm_user_agreement)
    end
    
end
