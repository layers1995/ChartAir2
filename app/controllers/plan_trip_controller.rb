class PlanTripController < ApplicationController
  
  def trip_details
    if not logged_in?
      redirect_to plantripinfo_url
    end
  end

  def results
  end

  def getFees(airplane, fbo)
	  # get the classification from the fbo, guess Jaime was right
		classification = Classification.find(fbo.classification_id)
		# get the category based on the classification and the airplane
		case classification.classification_description
		when "no fee"
			category = Category.find_by( :category_description => "no fee")
		when "flat rate"
			category = Category.find_by( :category_description => "flat rate")
		when "engine type"
			category = Category.find_by( :category_description => airplane.engine_class)
		when "make and model"
			category = Category.find_by( :category_description => airplane.model)
		else
			puts "That wasn't supposed to happen"
		end
		# return all fees where the category and fbo match what we're looking for. Should be up to 6 fees based on the different fee types
		return Fee.where( :category_id => category.id, :fbo_id => fbo.id)
	end
  
end
