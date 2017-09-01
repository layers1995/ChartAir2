include SeedsHelper # located at lib/seeds_helper.rb

def main
	Airplane.delete_all
	FeeType.delete_all
	City.delete_all
	Airport.delete_all
	Fbo.delete_all
	Classification.delete_all
	Category.delete_all
	Fee.delete_all

	addAirplanes("airplane_seed_data")
	addFeeTypes("fee_types")
	addClassifications("classification_types")
	addCategories("categories")
	#addCities("uscitiesv1.3.csv")
	addAirports("full_airport_data")
	addFbos("fbo_seed_data")
	addFboFolder("fbo_call_data")
	#addFeesAndUpdateFbos("survey_responses.tsv")
	addStartupTermData("survey_responses.tsv")

# TODO addFbos and addStartupTermData both add FBOs to the database, figure it out.
end

def addJetAirplanes()
	# The following planes are just the fleet owned by Jet Air
	cessna172 = Airplane.create({ :manufacturer => "cessna", :model => "172 skyhawk", :engine_class => "piston single", :weight => 2300, :height => 107, :wingspan => 433, :length => 326})
	cessna177 = Airplane.create({ :manufacturer => "cessna", :model => "177 cardinal", :engine_class => "piston single", :weight => 2500, :height => 103, :wingspan => 426, :length => 332})

	cessna425 = Airplane.create({ :manufacturer => "cessna", :model => "425 conquest i", :engine_class => "turboprop twin medium", :weight => 8600, :height => 151, :wingspan => 530, :length => 430})

	# engine class should technically be twin engine turbofan for cessna500 and cessna550, cessna550Bravo, and cessna560 ultra, but I don't want to change the schema right now.
	cessna500 = Airplane.create({ :manufacturer => "cessna", :model => "500 citation i", :engine_class => "light jet", :weight => 9502, :height => 157, :wingspan => 528, :length => 516})
	cessna550 = Airplane.create({ :manufacturer => "cessna", :model => "550 citation ii", :engine_class => "light jet", :weight => 13300, :height => 180, :wingspan => 626, :length => 567})
	
	# changed to medium and heavy jet for testing purposes
	cessna550Bravo = Airplane.create({ :manufacturer => "cessna", :model => "550 citation bravo", :engine_class => "midsize jet", :weight => 14800, :height => 180, :wingspan => 626, :length => 566})
	cessna560Ultra = Airplane.create({ :manufacturer => "cessna", :model => "560 citation ultra", :engine_class => "heavy jet", :weight => 16630, :height => 182, :wingspan => 649, :length => 587})
end

def addAirplanes(filename)
	airplaneTypes = File.open(Rails.root.join("db", "seed_data", filename))
	airplaneTypes.each do |curPlane|
		curPlane = curPlane.strip.downcase
		manufacturer, country, planeModel, planeClass, numCrew, numPassengers, engineType, range, emptyWeight, maxWeight, wingspan, wingArea, length, height = curPlane.split("\t")
		next unless engineType =~ /[0-9]+/
		numEngines = engineType.match(/[0-9]+/)[0].to_i
		engineType = engineType.gsub(/[0-9]/, "").strip
		engineCategory = nil
# multi engines
		if numEngines > 1 
			if engineType =~ /piston/
				engineCategory = "piston multi"
			elsif engineType =~ /turboprop/
				engineCategory = "turboprop multi"
			elsif engineType =~ /turbofan/
				engineCategory = "jet"
			elsif engineType =~ /turbojet/
				engineCategory = "turbojet"
			elsif engineType =~ /radial/
				engineCategory = "radial multi"
			elsif engineType =~ /turboshaft/
				engineCategory = "turboshaft multi"			
			elsif engineType =~ /propfan/
				engineCategory = "propfan multi"	
			elsif engineType =~ /rotary/
				engineCategory = "rotary multi"
			elsif engineType =~ /rocket/
				engineCategory = "rocket multi"
			end
# single engines
		elsif numEngines == 1
			if engineType =~ /piston/
				engineCategory = "piston single"
			elsif engineType =~ /turboprop/
				engineCategory = "turboprop single"
			elsif engineType =~ /turbofan/
				engineCategory = "jet"
			elsif engineType =~ /turbojet/
				engineCategory = "turbojet"
			elsif engineType =~ /radial/
				engineCategory = "radial single"
			elsif engineType =~ /turboshaft/
				engineCategory = "turboshaft single"
			elsif engineType =~ /propfan/
				engineCategory = "propfan single"
			elsif engineType =~ /rotary/
				engineCategory = "rotary single"
			elsif engineType =~ /rocket/
				engineCategory = "rocket single"
			end
		end
		Airplane.create({ :model => planeModel, :engine_class => engineCategory, :empty_weight => emptyWeight, :weight => maxWeight, :height => height, :wingspan => wingspan, :length => length, :manufacturer => manufacturer, :country => country, :plane_class => planeClass, :num_crew => numCrew, :num_passengers => numPassengers, :range => range, :wing_area => wingArea })
	end
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

def addCities(filename)
	cities = File.open(Rails.root.join("db", "seed_data", filename))
	cities.each do |curCity|
		curCity = curCity.strip.downcase
		cityName, cityNameAscii, stateCode, stateName, countyName, countyFips, latitude, longitude, population, source, id = curCity.split(",")
		City.create({ :name => cityName, :state => stateCode, :latitude => latitude, :longitude => longitude })
	end
end

def addAirports(filename)
	airports = File.open(Rails.root.join("db", "seed_data", filename))
	airports.each do |curAirport|
		curAirport = curAirport.strip.downcase
		airportCode, airportName, ownerPhone, managerPhone, latitude, longitude, state, city = curAirport.split("\t")
		curCity = City.find_by({ :name => city, :state => state })
# this will create a city if it's not found, but because we don't actually care about the city, it doesn't matter much, and commenting this out avoids duplicates
begin
		if curCity.nil?
			curCity = City.create({ :name => city, :state => state, :latitude => latitude, :longitude => longitude })
		end
end
		if curCity.nil?
			airports = Airport.create({ :airport_code => airportCode, :name => airportName.strip.downcase, :latitude => latitude, :longitude => longitude, :state => state, :ownerPhone => ownerPhone, :managerPhone => managerPhone})
		else
			airports = Airport.create({ :airport_code => airportCode, :name => airportName.strip.downcase, :latitude => latitude, :longitude => longitude, :state => state, :ownerPhone => ownerPhone, :managerPhone => managerPhone, :city => curCity })
		end
	end
end

# Add every FBO in a folder to the database
def addFboFolder(folderName)
	folderPath = Rails.root.join("db", "seed_data", folderName)
	Dir.foreach(folderPath) do |curFile|
	  next if curFile == '.' or curFile == '..' # do work on real items
	  filePath = Rails.root.join("db", "seed_data", "fbo_call_data", curFile)
	  addFbos(filePath)
	end
end

def addFbos(filePath)
	fbos = open(filePath).read
	
	fbos.each_line do |curFbo|
		curFbo = curFbo.strip.downcase

		state, city, airportName, airportCode, fboName, phone = curFbo.split("\t")
		phone1 = phone.split(", ")[0]
		phone2 = phone.split(", ")[1]

		if phone2.nil?
			phone2 = ""
		end

		#puts airportName

		curAirport = Airport.find_by(:name => airportName)

		if curAirport.nil?
			curAirport = Airport.find_by(:airport_code => airportCode)
		end

		if !curAirport.nil?
			Fbo.create({ :name => fboName, :phone => phone1, :alternate_phone => phone2, :airport => curAirport })
		end
	end
end


def addFeesAndUpdateFbos(filename)
	responseText = open(Rails.root.join("db", "seed_data", filename)).read
	responseText.each_line do |curRow|
		curRow = curRow.strip.downcase # get rid of new lines and make everything lowercase

		# split the excel sheet into individual variables using split
		state, city, airportName, airportCode, fboName, phoneNumbers, hasFees, classificationDesc, otherClassification, landingFee, rampFee, tieDownFee, facilityFee, callOutFee, hangarFee, otherFee, changeFrequency, feesWaived, fuelNeeded, contactPerson, callDate, infoQuality, hasFeeSheet, feeSheetLink, additionalInfo  = curRow.split("\t")

		feeClassification = Classification.find_by( :classification_description => classificationDesc )


		# We didn't make a column for tie down fees, so they're in the ramp fee instead.

		curAirport = Airport.find_by( :name => airportName)
		if curAirport.nil?
			curAirport = Airport.find_by( :airport_code => airportCode )
			# If the airport wasn't found, try adding a k to the front of the airport code and try again
			if curAirport.nil? and airportCode.length == 3
				newCode = "k" + airportCode
				curAirport = Airport.find_by( :airport_code => newCode )
			elsif
			# If the airport wasn't found, try removing the k from the front and trying again
				curAirport.nil? and airportCode.length == 4
				newCode = airportCode[1..3]
				curAirport = Airport.find_by( :airport_code => newCode )
			end
		end

		curFbo = Fbo.find_by(:name => fboName, :airport => curAirport)

		if !curFbo.nil?
			# this is what should happen
			if hasFees.strip == "no"
				curFbo.update( :classification => Classification.find_by( :classification_description => "no fee"))
				curCategory = Category.find_by( :category_description => "no fee")
				FeeType.find_each do |curFeeType|
					Fee.create( :fee_type => curFeeType, :fbo => curFbo, :category => curCategory, :price => 0)
				end
			elsif feeClassification.nil?
				# do nothing
			elsif classificationDesc == "flat rate"
				curCategory = Category.find_by( :category_description => "flat rate")
				curFbo.update( :classification => feeClassification )
				
				singleFeeHelper(landingFee, curCategory, curFbo, "landing")
				singleFeeHelper(rampFee, curCategory, curFbo, "ramp")
				singleFeeHelper(tieDownFee, curCategory, curFbo, "tie down")
				singleFeeHelper(facilityFee, curCategory, curFbo, "facility")
				singleFeeHelper(callOutFee, curCategory, curFbo, "call out")

			elsif classificationDesc == "engine type"
				curFbo.update( :classification => feeClassification )
				addFeeByEngineType(landingFee, curFbo, "landing")
				addFeeByEngineType(rampFee, curFbo, "ramp")
				addFeeByEngineType(tieDownFee, curFbo, "tie down")
				addFeeByEngineType(facilityFee, curFbo, "facility")
				addFeeByEngineType(callOutFee, curFbo, "call out")

			elsif classificationDesc == "weight"
				curFbo.update( :classification => feeClassification)
			elsif classificationDesc == "weight range"
			end

		else
			#puts fboName
		end
	end
end

# Because the call sheet was different during startup term, there needs to be a different excel sheet
def addStartupTermData(filename)
	responseText = open(Rails.root.join("db", "seed_data", filename)).read
	responseText.each_line do |curResponse|	
		curResponse = curResponse.strip.downcase # get rid of new lines and make everything lowercase

		# split the excel sheet into individual variables using split
		timestamp, city, state, fboName, airportName, airportCode, hasFees, classificationDesc, fuelWaivesFees, landingFee, rampFee, facilityFee, callOutFee, hangarFee, contactPerson, lastContacted, multipleFbos, extraInfo, chartsCollected = curResponse.split("\t")

		# We didn't make a column for tie down fees, so they're in the ramp fee instead. 
		# getTieDown fee returns an array, where the first index is the ramp fee, and the second is the tiedown fee. that code looks sexy
		rampFee, tieDownFee = getTieDownFee(rampFee)

		feeClassification = Classification.find_by( :classification_description => classificationDesc )

# Try to find the airport from the airport name. If that doesn't work, then try the airport code
		curAirport = Airport.find_by( :name => airportName)
		if curAirport.nil?
			curAirport = Airport.find_by( :airport_code => airportCode )
			# If the airport wasn't found, try adding a k to the front of the airport code and try again
			if curAirport.nil? and airportCode.length == 3
				newCode = "k" + airportCode
				curAirport = Airport.find_by( :airport_code => newCode )
			elsif
			# If the airport wasn't found, try removing the k from the front and trying again
				curAirport.nil? and airportCode.length == 4
				newCode = airportCode[1..3]
				curAirport = Airport.find_by( :airport_code => newCode )
			end
		end

		if curAirport.nil?
			#puts "name: " + airportName + ", code: " + airportCode
		end

# Create a new FBO based on the data in the call sheet. There will probably be duplicates in the database, but at least we'll have this info

		if !curAirport.nil?
			curFbo = Fbo.create( :name => fboName, :airport => curAirport, :classification => feeClassification )
	# If the FBO has no fees
			if hasFees.strip == "no"
				curCategory = Category.find_by( :category_description => "no fee")
				FeeType.find_each do |curFeeType|
					if curFeeType.fee_type_description == "call out"
						singleFeeHelper(callOutFee, curCategory, curFbo, curFeeType.fee_type_description)
					elsif curFeeType.fee_type_description == "hangar"
						# do nothing
					else
						singleFeeHelper(0, curCategory, curFbo, curFeeType.fee_type_description)
					end
				end
			elsif feeClassification.nil? or classificationDesc == ""
				# do nothing
			elsif classificationDesc == "flat rate"
				# If the current FBO has a flat rate fee
				curCategory = Category.find_by( :category_description => "flat rate")
				
				singleFeeHelper(landingFee, curCategory, curFbo, "landing")
				singleFeeHelper(rampFee, curCategory, curFbo, "ramp")
				singleFeeHelper(tieDownFee, curCategory, curFbo, "tie down")
				singleFeeHelper(facilityFee, curCategory, curFbo, "facility")
				singleFeeHelper(callOutFee, curCategory, curFbo, "call out")

			elsif classificationDesc == "engine type"
				# If the current FBO classifies by engine type
				addFeeByEngineType(landingFee, curFbo, "landing")
				addFeeByEngineType(rampFee, curFbo, "ramp")
				addFeeByEngineType(tieDownFee, curFbo, "tie down")
				addFeeByEngineType(facilityFee, curFbo, "facility")
				addFeeByEngineType(callOutFee, curFbo, "call out")

			elsif classificationDesc == "weight"
				#curFbo.update( :classification => feeClassification)

			elsif classificationDesc == "weight range"
				# do nothing
			end
		else
			#puts fboName
		end
	end
end

main










