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
    
  def current_user
    @current_user ||= User.find_by(id: session[:user_id])
  end
  
  #returns a list of all the airplanes currenly being used by the user
  def current_airplanes
    
    if(AirplaneUser.where(:user_id => session[:user_id]).first!=nil)
      
      airplanes=Array.new(AirplaneUser.where(:user_id => session[:user_id]).length)
      count=0
      
      for airplane in AirplaneUser.where(:user_id => session[:user_id]) do
        airplanes[count]=Airplane.where(:id => airplane.airplane_id).first
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
