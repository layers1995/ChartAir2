class PlanTripController < ApplicationController
  
  def trip_details
    if not logged_in?
      redirect_to plantripinfo_url
    end
  end

  def results
  end
  
end
