class UserMailer < ApplicationMailer
    
  default from: 'noreply@chartair.us'
    
  def welcome_email(user)
    @user = user
    @url  = 'http://chartair.us/login'
    mail(to: @user.email, subject: 'Welcome to ChartAir')
  end
  
  #an email confirming an upcoming trip to the user
  def confirmation_email(user, trip)
    @trip=Trip.find_by(:id => trip)
    @user= User.find_by(:id => user)
    @fbo= Fbo.find_by(:id => @trip.fbo_id)
    @airport = Airport.find_by(:id => @fbo.airport_id)
    @cost=@trip.cost
    @url  = 'http://chartair.us/trips'
    mail(to: @user.email, subject: 'Trip Confirmation')
  end
  
  #an email letting a user know there is an alteration to their upcoming trip
  def alteration_email(user, trip)
    @trip=Trip.find_by(:id => trip)
    @user = User.find_by(:id => user)
    @fbo= Fbo.find_by(:id => @trip.fbo_id)
    @airport = Airport.find_by(:id => @fbo.airport_id)
    @url  = 'http://chartair.us/trips'
    mail(to: @user.email, subject: 'Trip Alteration')
  end
  
  #an email letting a user know their trip has been cancelled
  def cancelled_email(user, trip)
    @trip=Trip.find_by(:id => trip)
    @user = User.find_by(:id => user)
    @fbo= Fbo.find_by(:id => @trip.fbo_id)
    @airport = Airport.find_by(:id => @fbo.airport_id)
    @url  = 'http://chartair.us/trips'
    mail(to: @user.email, subject: 'Trip Cancellation')
  end
  
  #used when a user books a trip
  def admin_trip_booked(user)
    @user=user
    @url="www.chartair.us/admin_main"
    mail(to: 'founders@chartair.us', subject: 'A User has Booked a Trip')
  end
  
  #when an fbo sends an email to us with their information
  def fbo_email_fees(fbo, fbo_info)
    
    #information needed for email
    @fbo=fbo
    @email_from_fbo=fbo_info
    
    mail(to: 'founders@chartair.us', subject: 'FBO Price Information')
  end
    
end
