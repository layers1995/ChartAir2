class UsersAirplanesController < ApplicationController
  
  def profile
    
    @user= current_user
    
    #user has planes
    if(current_airplanes!=nil)
      @airplanes= current_airplanes
    end
    
    gon.airplanes= Airplane.all
    @user_airplane= ""
    
  end
  
  def add_plane

    addedAirplane= Airplane.where(:model => params[:model])
    
    AirplaneUser.create(:airplane_id => addedAirplane.ids.first, :user_id => current_user.id, :tailnumber => params[:tailnumber])
    
    redirect_to "/profile"
    
  end
  
  def remove_plane
    
    AirplaneUser.find_by(:tailnumber => params[:tailnumber]).destroy
    
    redirect_to "/profile"
    
  end
  
  private

    def user_airplane_params
        params.require(:name).permit(:manufacturer, :tailnumber)
    end
  
end
