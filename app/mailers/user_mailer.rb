class UserMailer < ApplicationMailer
    
  default from: 'madison@chartair.us'
    
  def welcome_email(user)
    @user = user
    @url  = 'http://chartair.us/login'
    print "EMAIL SENT!?"
    mail(to: @user.email, subject: 'Welcome to ChartAir')
  end
  
  def admin_email(user, trip)
    @user= user
    mail(to: 'madison@chartair.us', subject: 'User Booked Trip')
  end
  
  def confirmation_email(user, trip)
    @user = user
    @airport=Airport.where(:id => trip.airport_id).name
    @fbo=Fbo.where(:id => trip.fbo_id).name
    @cost=trip.cost
    @url  = 'http://chartair.us/login'
    mail(to: @user.email, subject: 'Trip Confirmation')
  end
  
  def alteration_email(user, trip)
    @user = user
    @url  = 'http://chartair.us/trips'
    mail(to: @user.email, subject: 'Trip Alteration')
  end
  
  def cancelled_email(user, trip)
    @user = user
    @url  = 'http://chartair.us/trips'
    mail(to: @user.email, subject: 'Trip Cancellation')
  end
    
end
