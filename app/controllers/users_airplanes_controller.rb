class UsersAirplanesController < ApplicationController
  
  def profile
    @user= current_user
    #@airplanes= current_airplanes
    gon.airplanes= Airplane.all
    @user_airplane= ""
  end
  
  def add_plane
    
    addedAirplane= Airplane.where(:model => params[:model])
    
    airplanes_users.create(:user_id => current_user.id, :airplane_id => addedAirplane.id)
    
    redirect_to "/profile"
    
  end
  
  private

    def user_airplane_params
        params.require(:name).permit(:manufacturer)
    end
  
end
