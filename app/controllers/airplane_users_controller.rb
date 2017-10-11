class AirplaneUsersController < ApplicationController
  
  def profile
    
    @user= current_user
    if @user==nil
      redirect_to '/login'
    end
    
    #user has planes
    if(current_airplanes!=nil)
      @airplanes= current_airplanes
    end
    
    gon.airplanes= Airplane.all
    @user_airplane= AirplaneUser.new
  end
  
  def new
    @user_airplane= AirplaneUser.new
  end
  
  def create
    
    tailnumber= params[:airplane_user][:tailnumber].upcase
    
    if AirplaneUser.find_by(:tailnumber => tailnumber, :user_can_see => true, :user_id => current_user.id)!=nil
      flash[:notice]="Tail Number must be Unqiue"
      redirect_to "/profile" and return
    end

    addedAirplane= Airplane.where(:manufacturer => params[:airplane_user][:manufacturer], :model => params[:airplane_user][:model])

    AirplaneUser.create(:airplane_id => addedAirplane.ids.first, :user_id => current_user.id, :tailnumber => tailnumber, :user_can_see => true)
    
    redirect_to "/profile"
    
  end
  
  def remove_plane
    
    if AirplaneUser.find_by(:tailnumber => params[:tailnumber], :user_id => current_user.id, :user_can_see => true)!=nil
      
      airplane=AirplaneUser.find_by(:tailnumber => params[:tailnumber], :user_id => current_user.id, :user_can_see => true)
      airplane.update_attribute(:user_can_see, false)
      airplane.save
      
      redirect_to "/profile" and return
      
    end
    
  end
  
  private

    def user_airplane_params
        params.require(:tailnumber).permit(:airplane_id, :user_id, :manufacturer, :model)
    end
  
end

