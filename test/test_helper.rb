ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'minitest/reporters'
Minitest::Reporters.use!

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...
  def is_logged_in?
    !session[:user_id].nil?
  end
  
# THIS PROBABLY SHOULDN'T BE HERE BUT I DON'T KNOW HOW TO GET IT IN THE TESTS ANY OTHER WAY
# make sure to add any updates to the plan_trip_controller
	def getFees(airplane, fbo)
		multiplier = 1

		fees = Fee.where( :fbo_id => fbo.id )
		retFees = []

		fees.each do |curFee|
			classification = Classification.find(curFee.classification_id)
			# get the category based on the classification and the airplane
			case classification.classification_description
			when "no fee"
				retFees << curFee
				#category = Category.find_by( :category_description => "no fee" )
			when "flat rate"
				retFees << curFee
				#category = Category.find_by( :category_description => "flat rate" )
			when "engine type"
				if curFee.category.category_description == airplane.engine_class
					retFees << curFee
				end
				#category = Category.find_by( :category_description => airplane.engine_class )
				#fees = Fee.where( :category => category, :fbo => fbo, :classification => classification)
			when "make and model"
				if curFee.category.category_description == airplane.model
					retFees << curFee
				end
				#category = Category.find_by( :category_description => airplane.model )
			when "weight range"
				curCategory = curFee.category
				if curCategory.minimum < airplane.weight and curCategory.maximum > airplane.weight
					retFees << curFee
				end
				#planeWeight = airplane.weight
				#category = Category.find_by( "minimum < ? AND maximum > ?", planeWeight, planeWeight )
			when "weight"
				category = Category.find_by( :category_description => "weight" )
			else
				puts "That wasn't supposed to happen"
			end
		end
		return retFees
		# return all fees where the category and fbo match what we're looking for. Should be up to 6 fees based on the different fee types
		if !category.nil? # make sure that the category actually exists before trying to return anything
			fees = Fee.where( :category => category, :fbo => fbo )
			return fees
		else
			return nil
		end
	end

	def getFeeType(fees, feeType)
		fees.each do |curFee|
			if curFee.fee_type_description == feeType
				return curFee
			end
		end
	end

	def applyMultiplier(airplane, fees)
		feeArray = fees.to_a
		multiplier = 1
		fees.each do |curFee|
			case curFee.category.category_description
			when "weight"
				multiplier = airplane.weight / curFee.unit_magnitude
			end
			curFee.price += curFee.unit_price * multiplier
		end
		return feeArray	
	end

	def matchesAirplane(category, airplane)
	end

end
