class UsersAirplanesController < ApplicationController
  
  def index
    @user= current_user
    
    
    @user_airplane= ""
    
  end
  
  def add_airplane
    @user_airplane= user_airplane_params[:name]
  end
  
  private

    def user_airplane_params
      params.require(:name)
    end
  
end
