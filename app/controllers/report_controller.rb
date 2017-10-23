class ReportController < ApplicationController
  
  def index
    @rating=""
    userTrips=Trip.where(:user_id => current_user)
    
    trip_ids=[]
    count=1
    
    #see what trips that the user has taken that is valid to the parameters
    userTrips.each do |trip|
      #check to make sure the trip is completed and that there are no reviews
      if(trip.trip_status=="completed" && Report.find_by(:trip_id => trip.id)==nil)
        trip_ids[count]=trip.id
        count+=1
      end
    end
    
    @trips= Trip.where(:id => trip_ids)
  end
  
  def create
     
    if params["trip_rating"]!="" && params["fbo_rating"]!=""
      
        report=Report.new(:trip_id => params["trip_id"], :trip_rating => params["trip_rating"], :trip_comments => params["trip_comments"], :fbo_rating => params["fbo_rating"], :fbo_comments => params["fbo_comments"])
        report.save
        
        redirect_to trips_path and return
        
    end
    
    flash.now[:danger] = 'Please fill out number ratings'
    render template: "report/index"
    
  end
  
end
