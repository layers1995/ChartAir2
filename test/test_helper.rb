ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require "minitest/reporters"
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
		when "weight range"
			# I really doubt this will actually work, but that's the idea
			#category = Category.find_by( :minimum => airplane.weight, :maximum > airplane.weight)
		when "weight"
			# I think this is where I'm going to need to redesign the schema. Maybe just add a column to category saying how much per x the fee is charged. So if it's $5 every 1000 pounds, that new column would be 1000
		else
			puts "That wasn't supposed to happen"
		end

			# return all fees where the category and fbo match what we're looking for. Should be up to 6 fees based on the different fee types
		if !category.nil?
			retFees = Fee.where( :category => category, :fbo => fbo )
			if !retFees.nil?
				return retFees
			end
		end
	end

end
