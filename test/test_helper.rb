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

		classificationDesc = fbo.classification.classification_description

		if !landingTime.nil?
			landingTime = timeToMinutes(landingTime)
		end


		fees = Fee.where( :fbo => fbo )

		isEstimate = false

# Figure out if categories are missing so that the data retrieval is more complete
# WWWWHHHEEEEEEEEE
		if classificationDesc == "engine type"
# doesn't have piston multi light
			if !hasCategory(fees, "piston multi light") and hasCategory(fees, "piston multi heavy") and airplane.engine_class == "piston multi light"
				airplane.engine_class = "piston multi heavy"
				isEstimate = true
# doesn't have piston multi heavy
			elsif !hasCategory(fees, "piston multi heavy") and hasCategory(fees, "piston multi light") and airplane.engine_class == "piston multi heavy"
				airplane.engine_class = "piston multi light"
				isEstimate = true
# doesn't have turboprop single heavy
			elsif !hasCategory(fees, "turboprop single heavy") and hasCategory(fees, "turboprop single light") and airplane.engine_class == "turboprop single heavy"
				airplane.engine_class = "turboprop single light"
				isEstimate = true
# doesn't have turboprop single light
			elsif !hasCategory(fees, "turboprop single light") and hasCategory(fees, "turboprop single heavy") and airplane.engine_class == "turboprop single light"
				airplane.engine_class = "turboprop single heavy"
				isEstimate = true
# doesn't have turboprop twin light
			elsif !hasCategory(fees, "turboprop twin light") and hasCategory(fees, "turboprop twin medium") and airplane.engine_class == "turboprop twin light"
				airplane.engine_class = "turboprop twin medium"
				isEstimate = true
			elsif !hasCategory(fees, "turboprop twin light") and hasCategory(fees, "turboprop twin heavy") and airplane.engine_class == "turboprop twin light"
				airplane.engine_class = "turboprop twin heavy"
				isEstimate = true
# doesn't have turboprop twin medium
			elsif !hasCategory(fees, "turboprop twin medium") and hasCategory(fees, "turboprop twin heavy") and airplane.engine_class == "turboprop twin medium"
				airplane.engine_class = "turboprop twin heavy"
				isEstimate = true
			elsif !hasCategory(fees, "turboprop twin medium") and hasCategory(fees, "turboprop twin light") and airplane.engine_class == "turboprop twin medium"
				airplane.engine_class = "turboprop twin light"
				isEstimate = true
# doesn't have turboprop twin heavy
			elsif !hasCategory(fees, "turboprop twin heavy") and hasCategory(fees, "turboprop twin medium") and airplane.engine_class == "turboprop twin heavy"
				airplane.engine_class = "turboprop twin medium"
				isEstimate = true
			elsif !hasCategory(fees, "turboprop twin heavy") and hasCategory(fees, "turboprop twin light") and airplane.engine_class == "turboprop twin heavy"
				airplane.engine_class = "turboprop twin light"
				isEstimate = true
# doesn't have light jet
			elsif !hasCategory(fees, "light jet") and hasCategory(fees, "midsize jet") and airplane.engine_class == "light jet"
				airplane.engine_class = "midsize jet"
				isEstimate = true
			elsif !hasCategory(fees, "light jet") and hasCategory(fees, "super midsize jet") and airplane.engine_class == "light jet"
				airplane.engine_class = "super midsize jet"
				isEstimate = true
			elsif !hasCategory(fees, "light jet") and hasCategory(fees, "heavy jet") and airplane.engine_class == "light jet"
				airplane.engine_class = "heavy jet"
				isEstimate = true
# doesn't have midsize jet
			elsif !hasCategory(fees, "midsize jet") and hasCategory(fees, "super midsize jet") and airplane.engine_class == "midsize jet"
				airplane.engine_class = "super midsize jet"
				isEstimate = true
			elsif !hasCategory(fees, "midsize jet") and hasCategory(fees, "light jet") and airplane.engine_class == "midsize jet"
				airplane.engine_class = "light jet"
				isEstimate = true
			elsif !hasCategory(fees, "midsize jet") and hasCategory(fees, "heavy jet") and airplane.engine_class == "midsize jet"
				airplane.engine_class = "heavy jet"
				isEstimate = true
# doesn't have super midsize jet
			elsif !hasCategory(fees, "super midsize jet") and hasCategory(fees, "heavy jet") and airplane.engine_class == "super midsize jet"
				airplane.engine_class = "heavy jet"
				isEstimate = true
			elsif !hasCategory(fees, "super midsize jet") and hasCategory(fees, "midsize jet") and airplane.engine_class == "super midsize jet"
				airplane.engine_class = "midsize jet"
				isEstimate = true
			elsif !hasCategory(fees, "super midsize jet") and hasCategory(fees, "light jet") and airplane.engine_class == "super midsize jet"
				airplane.engine_class = "light jet"
				isEstimate = true
# doesn't have heavy jet
			elsif !hasCategory(fees, "heavy jet") and hasCategory(fees, "super midsize jet") and airplane.engine_class == "heavy jet"
				airplane.engine_class = "super midsize jet"
				isEstimate = true
			elsif !hasCategory(fees, "heavy jet") and hasCategory(fees, "midsize jet") and airplane.engine_class == "heavy jet"
				airplane.engine_class = "midsize jet"
				isEstimate = true
			elsif !hasCategory(fees, "heavy jet") and hasCategory(fees, "light jet") and airplane.engine_class == "heavy jet"
				airplane.engine_class = "light"
				isEstimate = true
			end
		end


		# For fees with the wrong engine type
		fees = fees.reject do |curFee|	
			if isEstimate
				curFee.is_estimate = true
			end
			curCategory = curFee.category.category_description

			if classificationDesc == "engine type" and curCategory != "flat rate" and curCategory != "no fee" and curCategory != "weight" and curCategory != "weight range"
				if curCategory == "jet"
					!airplane.engine_class =~ /jet/

				elsif curCategory == "turboprop"
					!airplane.engine_class =~ /turboprop/
				elsif curCategory == "turboprop single"
					!airplane.engine_class =~ /turboprop single/
				elsif curCategory == "turboprop multi"
					!airplane.engine_class =~ /turboprop multi/

				elsif curCategory == "piston"
					!airplane.engine_class =~ /piston/
				elsif curCategory == "piston multi"
					!airplane.engine_class =~ /piston multi/

				else
					curCategory != airplane.engine_class
				end
			end
		end

		# For fees that have a start time and end time that are in the wrong range
		fees = fees.reject do |curFee|
			curCategory = curFee.category.category_description

			if !curFee.start_time.nil? and !curFee.end_time.nil? and !landingTime.nil? # If the fee has a start time and an end time, make sure it falls in the right time period.
				
				startTime = curFee.start_time
				endTime = curFee.end_time
				# If the fee skips over midnight, add 1440 minutes (1 day) to the end time so the comparison works properly
				if startTime > endTime
					endTime += 1440
				end

				landingTime < startTime or landingTime > endTime
			end
		end

		# For fees that use the wrong time unit
		fees = fees.reject do |curFee|
			if !curFee.time_unit.nil? # reject fees that use the wrong time unit
				curFee.time_unit != timeUnit
			end
		end

		# For fees that are the wrong make/model
		fees = fees.reject do |curFee|
			curCategory = curFee.category.category_description

			if classificationDesc == "make and model" and curCategory != "flat rate" and curCategory != "no fee" and curCategory != "weight" and curCategory != "weight range"
				curCategory != airplane.model
			end
		end

		# For fees where the airplane weight doesn't fall in the weight range
		fees = fees.reject do |curFee|
			curCategory = curFee.category.category_description

			if curCategory == "weight range" and !curFee.unit_minimum.nil? and !curFee.unit_maximum.nil?
				airplane.weight < curFee.unit_minimum or airplane.weight > curFee.unit_maximum # reject fees if the airplane weight is less than the minimum or greater than the maximum
			end
		end

		fees = applyConditionalFees(airplane, fees, timeUnit, timeLength, landingTime)
		if fees.nil? or fees.length == 0
			puts "check"
			return nil
		else
			return fees
		end
	end

	def getFeeType(fees, feeType)
		fees.each do |curFee|
			if curFee.fee_type_description == feeType
				return curFee
			end
		end
	end

	def hasCategory(fees, category)
		fees.each do |curFee|
			if curFee.category.category_description == category
				return true
			end
		end
		return false
	end

	def applyConditionalFees(airplane, fees, timeUnit, timeLength, landingTime)
		feeArray = fees.to_a
		multiplier = 1
		fees.each do |curFee|

			tempTimeLength = timeLength

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
					if tempTimeLength >= 1 # wouldn't want negative times
						tempTimeLength -= 1
					end
					curFee.price += tempTimeLength * curFee.time_price

				else # However, if it's just $30/night, then staying for 1 night would be $30
					curFee.price += tempTimeLength * curFee.time_price
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
