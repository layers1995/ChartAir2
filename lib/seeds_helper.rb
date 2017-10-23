module SeedsHelper

def getTieDownFee(rampFee)
	# Tie down fees are listed under ramp fee because we didn't make a column for it in the spreadsheet.
	# this method separates the tie down fee from the ramp fee.
	tieDownFee = ""
	# the length check is to ignore the tie down fees that are tie down: single engine: 10, for example, because those are hard and I don't want to do them.
	if rampFee.include?("tie down")
		# look for a tie down fee
		tieDownFee = rampFee.match(/tie down: ?[a-z: ]*[0-9.]+/)
		# was a tie down fee found?
		if tieDownFee != nil
			# if one was found, pull the match from the ramp fee
			tieDownFee = tieDownFee[0]
			# remove the tie down text so just the number and category is left
			tieDownFee = tieDownFee.gsub(/tie down: /, "")
			tieDownFee = tieDownFee.strip
			# remove the tie down fee from the ramp fee
			rampFee = rampFee.gsub(/,?tie down: ?[a-z: ]*[0-9.]+/, "")
			rampFee = rampFee.gsub(/\A,/, "") # get rid of any comma that might be at the beginning
			rampFee = rampFee.strip
		end
	end
	return [rampFee, tieDownFee]
end

def singleFeeHelper(fee, fbo, feeType, classificationDescription)

	if classificationDescription == "other"
		classificationDescription = "nan"
	end

	fee = fee.strip.downcase
	foundFee = false

	feeTimeUnit = nil
	feeTimePrice = nil

	feeUnitPrice = nil
	feeUnitMagnitude = nil
	feeUnitMinimum = nil
	feeUnitMaximum = nil

	feeFreeTimeUnit = nil
	feeFreeTimeMagnitude = nil

	feeStartTime = nil
	feeEndTime = nil

	feePrice = nil

	category = Category.find_by( :category_description => "nan" )
	classification = Classification.find_by( :classification_description => "nan" )

	isEstimate = false


# first grab the categories

# fees that are done by weight
		if fee =~ /.+:/
			if fee =~ />[0-9]+ [a-z]+/
				#puts fee
				return # fuck these are hard
				category = Category.find_by( :category_description => "weight")
				classification = Classification.find_by( :classification_description => "weight" )
				feeUnitMinimum = fee.match(/[0-9]+/)[0].to_i # the category is going to be the thing just before the first colon
				feeUnitMaximum = 999999

# For fees that have different prices at different times. So far this has only applied to call out fees that have had flat rates
			elsif fee =~ /[0-9]{1,2}:[0-9]{1,2} ?- ?[0-9]{1,2}:[0-9]{1,2}: ?\$?[0-9.]+/
				category = Category.find_by( :category_description => "flat rate")
				classification = Classification.find_by( :classification_description => "flat rate" )

# Weight range
			elsif fee =~ /\A[0-9]+\s?-\s?[0-9]+\s?([a-z]+)?:\s?\$?[0-9.]+/
				category = Category.find_by( :category_description => "weight range")
				classification = Classification.find_by( :classification_description => "weight range")
				feeUnitMinimum = fee.scan(/[0-9]+/)[0]
				feeUnitMaximum = fee.scan(/[0-9]+/)[1]

# Weight
			elsif fee =~ /\$?[0-9.]+\s?per\s?[0-9]+/
				category = Category.find_by( :category_description => "weight")
				classification = Classification.find_by( :classification_description => "weight")
				feeUnitPrice = fee.match(/[0-9.]+/)[0]
				feeUnitMagnitude = fee.match(/per.+/)[0]
				feeUnitMagnitude = feeUnitMagnitude.match(/[0-9]+/)[0]

# otherwise, it should just be in the layout of category: fee
			else
				categoryDesc = fee.match(/.+:/)[0]
				categoryDesc = categoryDesc.gsub(/:/, "").strip
				categoryDesc = fixCategories(categoryDesc)	
				category = Category.find_by( :category_description => categoryDesc)
				classification = Classification.find_by( :classification_description => classificationDescription )
			end

# For fees where the price is based on weight
# This code is repeated, but I'm not sure which one to take out and don't feel like messing with it now.
		elsif fee =~ /\$?[0-9.]+\s?per\s?[0-9]+/
			category = Category.find_by( :category_description => "weight")
			classification = Classification.find_by( :classification_description => "weight")
			feeUnitPrice = fee.match(/[0-9.]+/)[0]
			feeUnitMagnitude = fee.match(/per.+/)[0]
			feeUnitMagnitude = feeUnitMagnitude.match(/[0-9]+/)[0]

# If the fee is in a range, we'll need to estimate
		elsif fee =~ /\A\$?[0-9.]+ ?- ?\$?[0-9.]+\z/
			# FOR SOME REASON, THIS CREATES DUPLICATES. I THINK IT'S BECAUSE DECIMALS ARE ROUNDED
			# SECOND LINE SO IT'S EASY TO FIND
			splitRangeIntoEngineTypes(fee, fbo, feeType)
			classification = Classification.find_by( :classification_description => "engine type")
			return


# For fees where the plane or category does not influence the price
# The stuff after the or is for callout fees that have different prices at different times. So far they have all been flat rates
		elsif fee =~ /\A\$?[0-9.]+/ or fee == "" or fee == "none" or fee == "n/a" or fee == "no"
			category = Category.find_by( :category_description => "flat rate")
			classification = Classification.find_by( :classification_description => "flat rate")

		else
			#puts "no category " + fee
		end

		if category.nil? or category.category_description.nil?
			#puts "category not found " + fee
			return
		end
# On to getting the fees

# If the fee has a price per time unit
		if fee =~ /\$?[0-9.]+\/[a-z]+/
			feeTime = fee.match(/\$?[0-9.]+\/[a-z]+/)[0]
			feeTimeUnit = feeTime.match(/[a-z]+/)[0]
			if feeTimeUnit == "night"
				feeTimeUnit = "day"
			end
			feeTimePrice = feeTime.match(/[0-9.]+/)[0]
			foundFee = true
		end

# If fees start at a certain time, and end at a certain time
		if fee =~ /[0-9]{1,2}:[0-9]{1,2} ?- ?[0-9]{1,2}:[0-9]{1,2}: ?\$?[0-9.]+/
			feeTimeRange = fee.match(/[0-9]{1,2}:[0-9]{1,2} ?- ?[0-9]{1,2}:[0-9]{1,2}: ?\$?[0-9.]+/)[0]
			feeStartTime = feeTimeRange.scan(/[0-9]{1,2}:[0-9]{1,2}/)[0]
			feeStartTime = timeToMinutes(feeStartTime)

			feeEndTime = feeTimeRange.scan(/[0-9]{1,2}:[0-9]{1,2}/)[1]
			feeEndTime = timeToMinutes(feeEndTime)

			feePrice = feeTimeRange.match(/[0-9.]+\z/)[0] # End of string is to ensure that it isn't a fee per time unit, those are covered already.
			foundFee = true
		end

# If the fee immediately follows the category
		if fee =~ /.+:\s?\$?[0-9.]+\z/
			feePrice = fee.match(/:\s?\$?[0-9.]+/)[0]
			feePrice = feePrice.match(/[0-9.]+/)[0]
			foundFee = true
		end

# If the fee is a flat rate
		if fee =~ /\A\$?[0-9.]+\z/
			feePrice = fee.match(/[0-9.]+/)[0]
			foundFee = true
		end

# If the fee is free for a bit
		if fee =~ /[0-9]+ [a-z]+ free/
			freeFee = fee.match(/[0-9]+ [a-z]+ free/)[0]
			feeFreeTimeMagnitude = freeFee.match(/[0-9]+/)[0]
			feeFreeTimeUnit = freeFee.match(/[a-z]+/)[0]
			if feeFreeTimeUnit == "night"
				feeFreetimeUnit = "day"
			end
			foundFee = true
		end

		feePrice = feeToNumber(feePrice)
		feeTimePrice = feeToNumber(feeTimePrice)
		feeUnitPrice = feeToNumber(feeUnitPrice)

		if classification.nil?
			#puts "the thing that fucked it up is " + classificationDescription
		elsif classification.classification_description == "nan"
			puts fbo.name + " " + fbo.airport.name + " " + fbo.airport.state + ": " + fee
		end

		feeType = FeeType.find_by( :fee_type_description => feeType )

		feeData = Fee.find_or_create_by(:fee_type => feeType, :category => category, :fbo => fbo, :price => feePrice, :time_unit => feeTimeUnit, :time_price => feeTimePrice, :unit_price => feeUnitPrice, :unit_magnitude => feeUnitMagnitude, :unit_minimum => feeUnitMinimum, :unit_maximum => feeUnitMaximum, :free_time_unit => feeFreeTimeUnit, :free_time_length => feeFreeTimeMagnitude, :start_time => feeStartTime, :end_time => feeEndTime, :is_estimate => false, :classification => classification )
		
		if !foundFee
			#puts fee
		end
	end

	def fixCategories(categoryDesc)
		case categoryDesc

		when "piston"
			categoryDesc = "piston"

		when "single engine", "single engine piston", "large single engine", "piston single light", "piston single heavy"
			categoryDesc = "piston single"

		when "piston multi", "twin engine"
			categoryDesc = "piston multi"

		when "small twin", "light twin piston", "piston multi light"
			categoryDesc = "piston multi light"

		when "large twin", "multi engine", "multi engine piston", "twin engine piston", "heavy twin piston", "piston multi heavy", "large twin piston"
			categoryDesc = "piston multi heavy"

		when "turboprop"
			categoryDesc = "turboprop"

		when "turboprop single light"
			categoryDesc = "turboprop single light"

		when "turboprop single heavy", "single engine turboprop", "turboprop", "light turboprop", "small turboprop"
			categoryDesc = "turboprop single heavy"

		when "turboprop twin", "heavy turboprop", "twin engine turboprop"
			categoryDesc = "turboprop twin"

		when "turboprop twin light"
			categoryDesc = "turboprop twin light"

		when "twin engine turboprop", "turboprop twin medium", "multi engine turboprop", "heavy turboprop", "large turboprop"
			categoryDesc = "turboprop twin medium"

		when "turboprop twin heavy"
			categoryDesc = "turboprop twin heavy"

		when "jet"
			categoryDesc = "jet"

		when "light jet", "very light jet", "ultra light jet", "small jet"
			categoryDesc = "light jet"

		when "midsize jet", "medium jet"
			categoryDesc = "midsize jet"

		when "super midsize jet"
			categoryDesc = "super midsize jet"

		when "heavy jet", "large jet", "mega jet"
			categoryDesc = "heavy jet"
# add very light jets and very heavy jets
		when "single engine jet"
			categoryDesc = "single engine jet"

		when "multi engine jet"
			categoryDesc = "multi engine jet"

		#else
		#	categoryDesc = nil
		end
		return categoryDesc
	end

	def splitRangeIntoEngineTypes(fee, fbo, feeType)
		# Using square roots for this might result in better numbers
		feeType = FeeType.find_by( :fee_type_description => feeType )

		lowEnd = fee.scan(/[0-9]+/)[0].to_f
		lowEnd = feeToNumber(lowEnd)
		highEnd = fee.scan(/[0-9]+/)[1].to_f
		highEnd = feeToNumber(highEnd)
		range = highEnd - lowEnd

		feeTimeUnit = "unkown"
		feeTimePrice = 0

		feeUnitPrice = 0
		feeUnitMagnitude = 0
		feeUnitMinimum = 0
		feeUnitMaximum = 0

		feeFreeTimeUnit = "unknown"
		feeFreeTimeMagnitude = 0

		feeStartTime = 0
		feeEndTime = 0

		feePrice = 0

		category = Category.find_by( :category_description => "nan")
		classification = Classification.find_by( :classification_description => "engine type" )

		isEstimate = false

		pistonSinglePrice = lowEnd
		pistonSinglePrice = pistonSinglePrice.to_i
		
		# I don't know if this line actually needs to be there.
		curFee = Fee.find_by( :fbo => fbo, :fee_type => feeType, :category => Category.find_by( :category_description => "piston single"), :is_estimate => true, :classification => classification )
		
		if curFee.nil?
			Fee.find_or_create_by( :fbo => fbo, :fee_type => feeType, :price => pistonSinglePrice, :category => Category.find_by( :category_description => "piston single"), :is_estimate => true, :classification => classification )
		end

		pistonMultiPrice = lowEnd + (range / 10)
		pistonMultiPrice = pistonMultiPrice.to_i
		curFee = Fee.find_by( :fbo => fbo, :fee_type => feeType, :category => Category.find_by( :category_description => "piston multi"), :is_estimate => true )
		if curFee.nil?
			Fee.find_or_create_by( :fbo => fbo, :fee_type => feeType, :price => pistonMultiPrice, :category => Category.find_by( :category_description => "piston multi"), :is_estimate => true, :classification => classification )
		end

		turbopropSingleLightPrice = lowEnd + (range / 9)
		turbopropSingleLightPrice = turbopropSingleLightPrice.to_i
		curFee = Fee.find_by( :fbo => fbo, :fee_type => feeType, :category => Category.find_by( :category_description => "turboprop single light"), :is_estimate => true )
		if curFee.nil?
			Fee.find_or_create_by( :fbo => fbo, :fee_type => feeType, :price => turbopropSingleLightPrice, :category => Category.find_by( :category_description => "turboprop single light"), :is_estimate => true, :classification => classification )
		end

		turbopropSingleHeavyPrice = lowEnd + (range / 7)
		turbopropSingleHeavyPrice = turbopropSingleHeavyPrice.to_i
		curFee = Fee.find_by( :fbo => fbo, :fee_type => feeType, :category => Category.find_by( :category_description => "turboprop single heavy"), :is_estimate => true )
		if curFee.nil?
			Fee.find_or_create_by( :fbo => fbo, :fee_type => feeType, :price => turbopropSingleHeavyPrice, :category => Category.find_by( :category_description => "turboprop single heavy"), :is_estimate => true, :classification => classification )
		end

		turbopropTwinLightPrice = lowEnd + (range / 6)
		turbopropTwinLightPrice = turbopropTwinLightPrice.to_i
		curFee = Fee.find_by( :fbo => fbo, :fee_type => feeType, :category => Category.find_by( :category_description => "turboprop twin light"), :is_estimate => true )
		if curFee.nil?
			Fee.find_or_create_by( :fbo => fbo, :fee_type => feeType, :price => turbopropTwinLightPrice, :category => Category.find_by( :category_description => "turboprop twin light"), :is_estimate => true, :classification => classification )
		end

		turbopropTwinMediumPrice = lowEnd + (range / 5)
		turbopropTwinMediumPrice = turbopropTwinMediumPrice.to_i
		curFee = Fee.find_by( :fbo => fbo, :fee_type => feeType, :category => Category.find_by( :category_description => "turboprop twin medium"), :is_estimate => true )
		if curFee.nil?
			Fee.find_or_create_by( :fbo => fbo, :fee_type => feeType, :price => turbopropTwinMediumPrice, :category => Category.find_by( :category_description => "turboprop twin medium"), :is_estimate => true, :classification => classification )
		end

		turbopropTwinHeavyPrice = lowEnd + (range / 4)
		turbopropTwinHeavyPrice = turbopropTwinHeavyPrice.to_i
		curFee = Fee.find_by( :fbo => fbo, :fee_type => feeType, :category => Category.find_by( :category_description => "turboprop twin heavy"), :is_estimate => true )
		if curFee.nil?
			Fee.find_or_create_by( :fbo => fbo, :fee_type => feeType, :price => turbopropTwinHeavyPrice, :category => Category.find_by( :category_description => "turboprop twin heavy"), :is_estimate => true, :classification => classification )
		end

		lightJetPrice = lowEnd + (range / 3)
		lightJetPrice = lightJetPrice.to_i
		curFee = Fee.find_by( :fbo => fbo, :fee_type => feeType, :category => Category.find_by( :category_description => "light jet"), :is_estimate => true )
		if curFee.nil?
			Fee.find_or_create_by( :fbo => fbo, :fee_type => feeType, :price => lightJetPrice, :category => Category.find_by( :category_description => "light jet"), :is_estimate => true, :classification => classification )
		end

		midsizeJetPrice = lowEnd + (range / 2)
		midsizeJetPrice = midsizeJetPrice.to_i
		curFee = Fee.find_by( :fbo => fbo, :fee_type => feeType, :category => Category.find_by( :category_description => "midsize jet"), :is_estimate => true )
		if curFee.nil?
			Fee.find_or_create_by( :fbo => fbo, :fee_type => feeType, :price => midsizeJetPrice, :category => Category.find_by( :category_description => "midsize jet"), :is_estimate => true, :classification => classification )
		end

		superMidsizeJetPrice = lowEnd + (range / 1.5)
		superMidsizeJetPrice = superMidsizeJetPrice.to_i
		curFee = Fee.find_by( :fbo => fbo, :fee_type => feeType, :category => Category.find_by( :category_description => "super midsize jet"), :is_estimate => true )
		if curFee.nil?
			Fee.find_or_create_by( :fbo => fbo, :fee_type => feeType, :price => superMidsizeJetPrice, :category => Category.find_by( :category_description => "super midsize jet"), :is_estimate => true, :classification => classification )
		end

		heavyJetPrice = lowEnd + range
		heavyJetPrice = heavyJetPrice.to_i
		curFee = Fee.find_by( :fbo => fbo, :fee_type => feeType, :category => Category.find_by( :category_description => "heavy jet"), :is_estimate => true )
		if curFee.nil?
			Fee.find_or_create_by( :fbo => fbo, :fee_type => feeType, :price => heavyJetPrice, :category => Category.find_by( :category_description => "heavy jet"), :is_estimate => true, :classification => classification )
		end
	end

	def feeToNumber(fee)

		# If the fee is already an integer or float, nothing needs to happen
		if fee.class == Fixnum or fee.class == Float
			# do nothing

		# If the fee isn't there, just return 0.
		elsif fee.nil? or fee.strip.length == 0
			fee = 0

		# if the fee is 0, change it to the number 0 instead of the string
		elsif fee.strip == "none" or fee.strip == "no" or fee.strip == "0" or fee.strip == "n/a"
			fee = 0
		end

		# if the fee is a string, set it to a float
		fee = fee.to_f

		# If the fee isn't an integer and isn't nil, then something went wrong.
		if fee.class != Float and !fee.nil?
			puts "get tie down fee: not a number" # just to figure out what broke exactly
			return nil
		end
		return fee
	end

	def timeToMinutes(time) # takes a time and turns it into the minute of that day so it's easier to compare.
		time = time.split(":")
		hour = time[0].to_i
		minute = time[1].to_i

		return hour * 60 + minute # minutes = 60*hours + minutes
	end

end