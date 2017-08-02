class PlanTripController < ApplicationController
  
  def trip_details
    if not logged_in?
      redirect_to home_path
    end
  end

  def results
  end
  
end
