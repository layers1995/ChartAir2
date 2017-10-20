class AdminMailer < ApplicationMailer
  
  default from: 'noreply@chartair.us'
  
  #used when a user books a trip
  def admin_trip_booked()
    
    #passed in records
    @user= user
    @trip= trip
    
    #information needed for template
    @airplane= Airplane.find_by(:id => AirplaneUser.find_by(:id => @trip.airplane_user_id).airplane_id)
    @fbo= Fbo.find_by(:id => @trip.fbo_id)
    @airport= Airport.find_by(Fbo.find_by:id => @trip.airport_id)
    @arrival_time= @trip.arrival_time
    @depart_time= @trip.depart_time
    @phone=@airport.managerPhone
    
    mail(to: 'madison@chartair.us', subject: 'User Booked Trip')
  end
  
  #when an fbo sends an email to us with their information
  def fbo_email_fees(fbo, fbo_info)
    
    #information needed for email
    @fbo=fbo
    @email_from_fbo=fbo_info
    
    mail(to: 'founders@chartair.us', subject: 'FBO Price Information')
  end
  
end
