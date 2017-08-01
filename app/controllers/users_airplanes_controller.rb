class UsersAirplanesController < ApplicationController
  
  def profile
    @user= current_user
    
    @user_airplane= ""
  end
  
  def add_plane
    
    planeName= params[:name]
    
    redirect_to "/profile"
    
  end
  
  private

    def user_airplane_params
        params.require(:name).permit(:manufacturer)
    end
  
end
