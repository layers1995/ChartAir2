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
	def getFees(airplane, fbo, timeUnit = nil, timeLength = 0, landingTime = nil)
		
		#multiplier = 1

		if !landingTime.nil?
			landingTime = timeToMinutes(landingTime)
		end

		fees = Fee.where( :fbo => fbo )

		fees = fees.reject do |curFee|
			curFee.price == 34 or curFee.price == 17

			curCategory = curFee.category.category_description

			if !curFee.start_time.nil? and !curFee.end_time.nil? # If the fee has a start time and an end time, make sure it falls in the right time period.
				startTime = curFee.start_time
				endTime = curFee.end_time
				# If the fee skips over midnight, add 1440 minutes (1 day) to the end time so the comparison works properly
				if startTime > endTime
					endTime += 1440
				end

				landingTime < startTime or landingTime > endTime # reject fees that are outside of the time the plane is landing
			end

			if !curFee.time_unit.nil? # reject fees that use the wrong time unit
				curFee.time_unit != timeUnit
			end

			#unit_price
			#unit_magnitude

			#free_time_unit
			airplane.weight < curFee.unit_minimum or airplane.weight > curFee.unit_maximum

			if curCategory == "weight range" and !curFee.unit_minimum.nil? and !curFee.unit_maximum.nil?
				airplane.weight < curFee.unit_minimum or airplane.weight > curFee.unit_maximum # reject fees if the airplane weight is less than the minimum or greater than the maximum
			end

			if curCategory == "weight"
				# I probably don't need to reject any of these
			end
		end

		puts fees.length
		fees = applyConditionalFees(airplane, fees, timeUnit, timeLength, landingTime)
		if fees.nil? or fees.length == 0
			puts "check"
			return nil
		else
			return fees
		end

	end



=begin
		classification = Classification.find(fbo.classification_id)
		# get the category based on the classification and the airplane
		case classification.classification_description
		when "no fee"
			category = Category.find_by( :category_description => "no fee" )
		when "flat rate"
			category = Category.find_by( :category_description => "flat rate" )
		when "engine type"
			category = Category.find_by( :category_description => airplane.engine_class )
		when "make and model"
			category = Category.find_by( :category_description => airplane.model )
		when "weight range"
			planeWeight = airplane.weight
			category = Category.find_by( "minimum < ? AND maximum > ?", planeWeight, planeWeight )
		when "weight"
			category = Category.find_by( :category_description => "weight" )
			#multiplier = airplane.weight / curFee.unit_magnitude
		else
			puts "That wasn't supposed to happen"
		end

		# return all fees where the category and fbo match what we're looking for. Should be up to 6 fees based on the different fee types
		if !category.nil? # make sure that the category actually exists before trying to return anything
			fees = Fee.where( category: [category, Category.find_by( :category_description => "flat rate")], :fbo => fbo )

			fees = fees.reject do |curFee|
# Get rid of the fees that aren't supposed to be there for this search

				if !curFee.start_time.nil? and !curFee.end_time.nil? # If the fee has a start time and an end time, make sure it falls in the right time period.

					startTime = timeToMinutes(curFee.start_time)
					endTime = timeToMinutes(curFee.end_time)
					
					# If the fee skips over midnight, add 1440 minutes (1 day) to the end time so the comparison works properly
					if startTime > endTime
						endTime += 1440
					end
					landingTime < startTime or landingTime > endTime

				elsif !curFee.time_unit.nil? # reject fees that use the wrong time unit
					curFee.time_unit != timeUnit
				end
			end

			fees = applyMultiplier(airplane, fees, timeUnit, timeLength, landingTime)
			return fees
		else
			return nil
		end
	end
=end

	def getFeeType(fees, feeType)
		fees.each do |curFee|
			if curFee.fee_type_description == feeType
				return curFee
			end
		end
	end

	def applyConditionalFees(airplane, fees, timeUnit, timeLength, landingTime)
		feeArray = fees.to_a
		multiplier = 1
		fees.each do |curFee|
			case curFee.category.category_description
			when "weight", !curFee.unit_magnitude.nil?, !fees.nil?
				multiplier = airplane.weight / curFee.unit_magnitude
			end

			if !curFee.unit_price.nil?
				curFee.price += curFee.unit_price * multiplier
			end

			# Check the case where the fbo gives free time before charging
			if !curFee.free_time_unit.nil? and !curFee.free_time_length.nil? and !curFee.time_unit.nil? and !curFee.time_price.nil? and !timeLength.nil?
				curFee.price += (timeLength - curFee.free_time_length) * curFee.time_price

			# If they don't do free stuff
			elsif !curFee.time_unit.nil? and !curFee.time_price.nil? and curFee.free_time_length.nil?

				if curFee.price != 0 # If a fee is something like $50 + $30/night, it's $50 the first night, not $80
					
					if timeLength >= 1 # wouldn't want negative times
						timeLength -= 1
					end
					curFee.price += timeLength * curFee.time_price

				else # However, if it's just $30/night, then staying for 1 night would be $30
					curFee.price += timeLength * curFee.time_price
				end
			end		

		end
		return feeArray	
	end

	def timeToMinutes(time) # takes a time and turns it into the minute of that day so it's easier to compare.
		time = time.strftime("%R") # Change the time to a string of format "HH:MM"
		hour = (time[0] + time[1]).to_i
		minute = (time[3] + time[4]).to_i

		return hour * 60 + minute # minutes = 60*hours + minutes
	end
end
