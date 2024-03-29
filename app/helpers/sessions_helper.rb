module SessionsHelper
    
  def log_in(user)
    session[:user_id] = user.id
  end
  
  def log_out
    session.delete(:user_id)
    @current_user = nil
  end
  
  def logged_in?
    !current_user.nil?
  end
  
  def admin_logged_in?
    !current_user.nil? && current_user.name==="OliviaCanEat"
  end
    
  def current_user
    @current_user ||= User.find_by(id: session[:user_id])
  end
  
  #returns a list of all the airplanes currenly being used by the user that the user can see
  def current_airplanes
    
    if(AirplaneUser.where(:user_id => session[:user_id]))
      
      #table all airplanes ids and tailnumbers used by a spicific user
      airplanes=Array.new(AirplaneUser.where(:user_id => session[:user_id], :user_can_see => true).length)
      count=0
      
      #creates an array of all the ids from the airplanes
      for airplane in AirplaneUser.where(:user_id => session[:user_id], :user_can_see => true) do
        curAirplane= Airplane.find_by(:id => airplane.airplane_id)
        airplanes[count]={ "tailnumber" => airplane.tailnumber, "model" => curAirplane.model, "manufacturer" =>  curAirplane.manufacturer}
        count+=1
      end
      
      @current_airplanes= airplanes
      
    end
    
  end

  
  def remember(user)
    user.remember
    cookies.permanent.signed[:user_id] = user.id
    cookies.permanent[:remember_token] = user.remember_token
  end
  
  def current_user
    if (user_id = session[:user_id])
      @current_user ||= User.find_by(id: user_id)
    elsif (user_id = cookies.signed[:user_id])
      user = User.find_by(id: user_id)
      if user && user.authenticated?(cookies[:remember_token])
        log_in user
        @current_user = user
      end
    end
  end
   
     # Forgets a persistent session.
  def forget(user)
    user.forget
    cookies.delete(:user_id)
    cookies.delete(:remember_token)
  end

  # Logs out the current user.
  def log_out
    forget(current_user)
    session.delete(:user_id)
    @current_user = nil
  end
    
end
