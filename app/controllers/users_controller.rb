class UsersController < ApplicationController
  
  def index
    redirect_to 'new'
  end
  
  def request_account
    @request=""
  end
  
  def create_request
    curRequest=Request.create(:email => params["email"], :email_confirm => params["email_confirm"], :sent => false)
    if curRequest.save
      flash[:success]="Your request has been sent, someone from our team will respond to you soon!"
      redirect_to landing_path
    else
      flash[:notice]="Email did not match email confirmation"
      @request=""
      render 'request_account'
    end
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
        #UserMailer.welcome_email(@user).deliver_now
        log_in @user
        redirect_to home_path
      else
        render 'new_user'
      end
    
  end
  
  private

    def user_params
      params.require(:user).permit(:name, :email, :email_confirm, :betakey, :password, :password_confirmation, :confirm_user_agreement)
    end
    
end
