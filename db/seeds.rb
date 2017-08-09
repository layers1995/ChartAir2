def main

	Airplane.delete_all
	FeeType.delete_all
	City.delete_all
	Airport.delete_all
	Fbo.delete_all
	Classification.delete_all
	Category.delete_all
	Fee.delete_all

	addAirplanes()
	addFeeTypes("fee_types")
	addClassifications("classification_types")
	addCategories("categories")
	addAirports("airport_seed_data") # also adds cities
	addFbos("fbo_seed_data")
	addFeesAndUpdateFbos("survey_responses.tsv")
end


def addAirplanes()
	# The following planes are just the fleet owned by Jet Air
	cessna172 = Airplane.create({ :manufacturer => "cessna", :model => "172 skyhawk", :engine_class => "single engine", :weight => 2300, :height => 107, :wingspan => 433, :length => 326})
	cessna177 = Airplane.create({ :manufacturer => "cessna", :model => "177 cardinal", :engine_class => "single engine", :weight => 2500, :height => 103, :wingspan => 426, :length => 332})

	cessna425 = Airplane.create({ :manufacturer => "cessna", :model => "425 conquest i", :engine_class => "twin engine turboprop", :weight => 8600, :height => 151, :wingspan => 530, :length => 430})

	# engine class should technically be twin engine turbofan for cessna500 and cessna550, cessna550Bravo, and cessna560 ultra, but I don't want to change the schema right now.
	cessna500 = Airplane.create({ :manufacturer => "cessna", :model => "500 citation i", :engine_class => "light jet", :weight => 9502, :height => 157, :wingspan => 528, :length => 516})
	cessna550 = Airplane.create({ :manufacturer => "cessna", :model => "550 citation ii", :engine_class => "light jet", :weight => 13300, :height => 180, :wingspan => 626, :length => 567})
	
	# changed to medium and heavy jet for testing purposes
	cessna550Bravo = Airplane.create({ :manufacturer => "cessna", :model => "550 citation bravo", :engine_class => "medium jet", :weight => 14800, :height => 180, :wingspan => 626, :length => 566})
	cessna560Ultra = Airplane.create({ :manufacturer => "cessna", :model => "560 citation ultra", :engine_class => "heavy jet", :weight => 16630, :height => 182, :wingspan => 649, :length => 587})
end

def addFeeTypes(filename)
	feeTypes = File.open(Rails.root.join("db", "seed_data", filename))
	feeTypes.each do |curFeeType|
		FeeType.create({ :fee_type_description => curFeeType.strip })
	end
end

def addClassifications(filename)
	classificationTypes = File.open(Rails.root.join("db", "seed_data", filename))
	classificationTypes.each do |curClassificationType|
		Classification.create({ :classification_description => curClassificationType.strip })
	end
end

def addCategories(filename)
	categoryTypes = File.open(Rails.root.join("db", "seed_data", filename))
	categoryTypes.each do |curCategoryType|
		curCategoryType = curCategoryType.split(",")
		Category.create({ :category_description => curCategoryType[0], :minimum => curCategoryType[1], :maximum => curCategoryType[2] })
	end
end

def addAirports(filename)
	airports = File.open(Rails.root.join("db", "seed_data", filename))
	airports.each do |curAirport|
		curAirport = curAirport.strip
		airportCode, airportName, ownerPhone, managerPhone, latitude, longitude, state, city = curAirport.split("\t")

		curCity = City.find_by({ :name => city, :state => state })
		if curCity.nil?
			curCity = City.create({ :name => city, :state => state, :latitude => latitude, :longitude => longitude })
		end
		airports = Airport.create({ :airport_code => airportCode, :name => airportName.strip.downcase, :latitude => latitude, :longitude => longitude, :state => state, :ownerPhone => ownerPhone, :managerPhone => managerPhone, :city_id => curCity.id })
	end
end

def addFbos(filename)
	fbos = open(Rails.root.join("db", "seed_data", filename)).read
	
	fbos.each_line do |curFbo|
		curFbo = curFbo.strip.downcase

		fboName, phone, airportName = curFbo.split("\t")
		phone1 = phone.split(", ")[0]
		phone2 = phone.split(", ")[1]

		if phone2.nil?
			phone2 = ""
		end

		#puts airportName

		curAirport = Airport.find_by(:name => airportName)

		if curAirport.nil?
			#curAirport = Airport.find_by(:airport_code => )
		else
			Fbo.create({ :name => fboName, :airport_id => Airport.find_by(:name => airportName).id })
		end
	end
end



def addFeesAndUpdateFbos(filename)
	responseText = open(Rails.root.join("db", "seed_data", filename)).read
	responseText.each_line do |curResponse|
		curResponse = curResponse.strip.downcase # get rid of new lines and make everything lowercase

		# split the excel sheet into individual variables using split
		timestamp, city, state, fboName, airportName, airportCode, hasFees, feeClassification, fuelWaivesFees, landingFee, rampFee, facilityFee, callOutFee, hangarFee, contactPerson, lastContacted, multipleFbos, extraInfo, chartsCollected = curResponse.split("\t")

		classificationDesc = feeClassification
		feeClassification = Classification.find_by( :classification_description => classificationDesc )


		# We didn't make a column for tie down fees, so they're in the ramp fee instead.
		tieDownFee = getTieDownFee(rampFee)

		curAirport = Airport.find_by( :name => airportName)
		if curAirport.nil?
			curAirport = Airport.find_by( :airport_code => airportCode)
		end

		if !curAirport.nil?
			curFbo = Fbo.find_by(:name => fboName, :airport_id => curAirport.id) 
		end

		if curFbo != nil
			# this is what should happen
			if hasFees.strip == "no"
				curFbo.update( :classification => Classification.find_by( :classification_description => "no fee"))
				curCategory = Category.find_by( :category_description => "no fee")
				FeeType.find_each do |curFeeType|
					Fee.create( :fee_type => curFeeType, :fbo => curFbo, :category => curCategory, :price => 0)
				end

			elsif !feeClassification.nil? and classificationDesc == "flat rate"
				curCategory = Category.find_by( :category_description => "flat rate")
				curFbo.update( :classification => feeClassification )
				
				singleFeeHelper(landingFee, curCategory, curFbo, "landing")
				singleFeeHelper(rampFee, curCategory, curFbo, "ramp")
				singleFeeHelper(tieDownFee, curCategory, curFbo, "tie down")
				singleFeeHelper(facilityFee, curCategory, curFbo, "facility")
				singleFeeHelper(callOutFee, curCategory, curFbo, "call out")

			elsif !feeClassification.nil? and classificationDesc == "engine type"
				curFbo.update( :classification => feeClassification )
				addFeeByEngineType(landingFee, curFbo, "landing")
				addFeeByEngineType(rampFee, curFbo, "ramp")
				addFeeByEngineType(tieDownFee, curFbo, "tie down")
				addFeeByEngineType(facilityFee, curFbo, "facility")
				addFeeByEngineType(callOutFee, curFbo, "call out")
			end

		else
			# check where the fboName is different
			# I think a lot of these are missing because they are at private airports that are open to the public. I need to rerun the airport crawler now that it's fixed.
			# puts fboName
		end
	end
end

def getTieDownFee(rampFee)
	# Tie down fees are listed under ramp fee because we didn't make a column for it in the spreadsheet.
	# this method separates the tie down fee from the ramp fee.
	tieDownFee = ""
	# the length check is to ignore the tie down fees that are tie down: single engine: 10, for example, because those are hard and I don't want to do them.
	if rampFee.include?("tie down") and rampFee.length < 20
		# look for a tie down fee
		tieDownFee = rampFee.match(/tie down: [0-9]*/)
		# was a tie down fee found?
		if tieDownFee != nil
			# if one was found, pull the match from the ramp fee
			tieDownFee = tieDownFee[0]
			# remove the tie down text so just the number and category is left
			tieDownFee = tieDownFee.gsub(/tie down: /, "")
			# remove the tie down fee from the ramp fee
			# BUG! doesn't account for tie down fees of the format tiedown: single engine: XX
			rampFee = rampFee.gsub(/tie down: [0-9]*/, "")


			# I don't think these are actually needed but I don't want to delete them in case they are.
			#if rampFee != nil
			#	rampFee = rampFee[0]
			#end
		end
	end
	return tieDownFee
end

def singleFeeHelper(feePrice, category, fbo, feeType)
	feePrice = feeToNumber(feePrice)
	feeType = FeeType.find_by( :fee_type_description => feeType )
	Fee.create(:fee_type_id => feeType.id, :category => category, :fbo => fbo, :price => feePrice)
	#puts fbo.name + ": " + feeType.fee_type_description + ": " + category.category_description + ": " + feePrice.to_s
end

def feeToNumber(fee)
	# If the fee is already an integer, nothing needs to happen
	if fee.class == Fixnum or fee.nil?
		return fee
	end

	# if the fee isn't there, just set it to nil
	if fee.length == 0
		fee = nil

	# if the fee is 0, change it to the number 0 instead of the string
	elsif fee == "none" or fee == "no" or fee == "0"
		fee = 0
	end

	# if the fee is a string, set it to an int
	fee = fee.to_i

	# If the fee isn't an integer and isn't nil, then something went wrong.
	if fee.class != Fixnum and !fee.nil?
		#puts "get tie down fee: not a number" # just to figure out what broke exactly
		return nil
	end
	return fee
end

def addFeeByEngineType(feeList, fbo, feeTypeDescription)
	feeList.split(",").each do |curFee|
		if curFee =~ /^([a-z ]+:[ $]+?[0-9]+|[$]?[0-9]+)/
			curFee = curFee.match(/^([a-z ]+:[ $]+?[0-9]+|[0-9]+)/)[0] # get the fee for the current category
			feePrice = curFee.match(/[0-9]{1,4}/)[0] # narrow it down to just the fee itself
			if curFee =~ /[a-z ]+/
				categoryDesc = curFee.match(/[a-z ]+/)[0].strip # grab the category description as well
			end

			case categoryDesc
			when "single engine"
				categoryDesc = "piston single"

			when "small twin"
				categoryDesc = "piston multi light"

			when "large twin", "twin engine", "multi engine"
				categoryDesc = "piston multi heavy"

			when "turboprop single light"
				categoryDesc = "turboprop single light"

			when "single engine turboprop"
				categoryDesc = "turboprop single heavy"

			when "turboprop twin light"
				categoryDesc = "turboprop twin light"

			when "twin engine turboprop"
				categoryDesc = "turboprop twin medium"

			when "turboprop twin heavy"
				categoryDesc = "turboprop twin heavy"

			when "light jet"
				categoryDesc = "light jet"

			when "midsize jet", "medium jet", "jet"
				categoryDesc = "midsize jet"

			when "super midsize jet"
				categoryDesc = "super midsize jet"

			when "heavy jet", "large jet"
				categoryDesc = "heavy jet"

			else
				categoryDesc = nil
			end

			
			if !categoryDesc.nil?
				#puts categoryDesc + ": " + feePrice
				category = Category.find_by( :category_description => categoryDesc )
				singleFeeHelper(feePrice, category, fbo, feeTypeDescription)
			end
=begin
		elsif curFee =~ /^[0-9]{1,4}/ # if the fee isn't split up by types and is just a single fee
			curFee = curFee.match(/[0-9]{1,4}/)[0]
			singleFeeHelper(curFee, category, fbo, feeTypeDescription)
=end
		end
	end	
end

main










