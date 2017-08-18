class AdminController < ApplicationController
  
  def admin_login
    
  end
  
  def admin_create
    
    if(params[:session][:name]==="OliviaCanEat")
      
      user = User.find_by(name: params[:session][:name])
      if user && user.authenticate(params[:session][:password])
        log_in user
        remember user
        redirect_to admin_main_path
      else
        flash.now[:danger] = 'Invalid email/password combination'
        render 'new'
      end
      
    end
    
  end

  def admin_main
    
    if !admin_logged_in?
      redirect_to admin_login_path
    end

    @trips=Trip.where(:trip_status => "pending")
    @reports=Report.where(:status => nil)
    @seen_reports=Report.where(:status => "seen")
    
  end
  
  def confirm_trip
    
    trip = Trip.find_by(:id => params[:trip_id])
    trip.trip_status="confirmed"
    trip.save
    
    redirect_to "/admin_main"
    
  end
  
  def raise_issue_trip
    
  end
  
  def problem_trip
    
    @trip = params[:trip_id]
    @issue= params[:problem]
    @problem=""
    
  end
  
  def post_problem
    
    trip= Trip.find_by(:id =>params[:trip_id])
    
    trip.trip_status= params[:problem]
    trip.issue = params[:reason]
    trip.save
    
    redirect_to admin_main_path
  end
  
  def seen_report
    report=Report.find_by(:id => params["id"])
    report.status="seen"
    report.save
    redirect_to admin_main_path
  end
  
end
