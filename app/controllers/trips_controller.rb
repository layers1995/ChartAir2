class TripsController < ApplicationController
  
  def index
    temptrips=Trip.where(:user_id => current_user).order(arrival_time: :asc)
    
    #change trips from pending to completed
    if temptrips!=nil
     temptrips.each do |trip|
       if(trip.trip_status==="confirmed" && trip.arrival_time.past?)
         trip.trip_status="completed"
         trip.save
       end
     end
    end
    
    @nextTrips= Trip.where(:user_id => current_user, :trip_status => ["issue","pending", "cancelled", "confirmed"]).order(arrival_time: :asc)
    @prevTrips= Trip.where(:user_id => current_user, :trip_status => "completed").order(arrival_time: :asc)
  end
  
  def resolve_trip
    
    trip=Trip.find_by(:id => params[:trip])
    
    #if the user chooses to remove trip
    if params[:resolution]==="remove"
      trip.destroy
      redirect_to trips_path and return
    end
    
    #if user plans a new trip
    if params[:resolution]==="plan_trip"
      trip.destroy
      redirect_to plantrip_path and return
    end
    
    #if user confirms trip
    if params[:resolution]==="confirm"
      trip.trip_status="confirmed"
      trip.save
      redirect_to trips_path and return
    end
    
  end
  
  def resolution
    @problem= params[:reason]
    @trip= params[:trip]
    @issue= Trip.find_by(:id => params[:trip]).issue
  end
  
  def new_trip
    
    #create information needed to save the trip
    airport_id= Airport.find_by(:name => params[:airport]).id
    fbo_id= Fbo.find_by(:name => params[:fbo]).id
    user_id= current_user.id
    trip_status= "pending";
    airplane_user_id=AirplaneUser.find_by(:tailnumber => params[:tailnumber], :user_can_see => true).id
    arrival_time=DateTime.parse(params[:start_datetime])
    
    if arrival_time < Date.tomorrow
      flash[:notice] = "Trips must be booked at least 24 hours in advance."
      redirect_to :back and return 
    end
    
    Trip.create(:airport_id => airport_id, :fbo_id => fbo_id, :user_id => user_id, :tailnumber => params[:tailnumber], :airplane_user_id => airplane_user_id ,:cost => params["cost"].to_i, :detail => params[:detail], :trip_status => trip_status, :arrival_time => arrival_time)
    
    redirect_to "/trips"
    
  end
  
  def book_trip
    #needed information
    @tailnumber=params["tailnumber"]
    @airport=params["airport"]
    @fbo=params["fbo"]
    @cost=params["cost"]
    @time= DateTime.parse(params["time"])
    @time2= DateTime.parse(params["time2"])
    #holder for trip form
    @trip=""
  end
  
  private
  
  def trip_params
    params.require(:date).permit(:fbo, :airport, :tailnumber, :cost)
  end
  
  def formatTime(timeArray)
    val=timeArray[1]+"/"+timeArray[2]+"/"+timeArray[0]+" "
    
    if(timeArray[3].to_i>12)
      timeArray[3]=timeArray[3].to_i-12;
      val=val+timeArray[3].to_s+":"+timeArray[4]+ " PM"
    else
      val=val+timeArray[3].to_s+":"+timeArray[4]+ " AM"
    end
    
    return DateTime.strptime(val, "%m/%d/%Y %H:%M %p")    
  end
  
end
