class ReportController < ApplicationController
  
  def index
    @trip_id=params[:trip_id]
  end
  
  def create
     
    if params[:report]["trip_rating"]!="" && params[:report]["fbo_rating"]!=""
      
        report=Report.new(:trip_id => params[:report]["trip_id"], :trip_rating => params[:report]["trip_rating"], :trip_comments => params[:report]["trip_comments"], :fbo_rating => params[:report]["fbo_rating"], :fbo_comments => params[:report]["fbo_comments"])
        report.save
        
        redirect_to trips_path and return
        
    end
    
    flash.now[:danger] = 'Please fill out number ratings'
    render template: "report/index"
    
  end
  
end
