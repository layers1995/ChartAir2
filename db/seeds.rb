include SeedsHelper # located at lib/seeds_helper.rb

def main
# Delete stuff
=begin
	Fee.delete_all
	Category.delete_all

	Fbo.delete_all
	Airport.delete_all
	City.delete_all

	Airplane.delete_all

	FeeType.delete_all
	Classification.delete_all
=end

# Add stuff	

	addAirplanes("airplane_seed_data")
	addFeeTypes("fee_types")
	addClassifications("classification_types")

	addCategories("categories")

	#addCities("uscitiesv1.3.csv") # makes the website run slowly... meh

	#addAirports("tx_call_sheet")
	addAirports("full_airport_data")

	addFboFolder("fbo_call_data")

	#addFeesAndUpdateFbos(Rails.root.join("db", "seed_data", "call_sheets", "tx_call_sheet.tsv"))
	addFeeFolder("call_sheets")
	#addFeeFolder("fbo_fee_sheets")
	addStartupTermData("survey_responses.tsv")

# TODO addFbos and addStartupTermData both add FBOs to the database, figure it out. Solution was to remove the fbos from states that we covered during startup term.
end

def addJetAirplanes()
	# The following planes are just the fleet owned by Jet Air
	cessna172 = Airplane.find_or_create_by({ :manufacturer => "cessna", :model => "172 skyhawk", :engine_class => "piston single", :weight => 2300, :height => 107, :wingspan => 433, :length => 326})
	cessna177 = Airplane.find_or_create_by({ :manufacturer => "cessna", :model => "177 cardinal", :engine_class => "piston single", :weight => 2500, :height => 103, :wingspan => 426, :length => 332})

	cessna425 = Airplane.find_or_create_by({ :manufacturer => "cessna", :model => "425 conquest i", :engine_class => "turboprop twin medium", :weight => 8600, :height => 151, :wingspan => 530, :length => 430})

	# engine class should technically be twin engine turbofan for cessna500 and cessna550, cessna550Bravo, and cessna560 ultra, but I don't want to change the schema right now.
	cessna500 = Airplane.find_or_create_by({ :manufacturer => "cessna", :model => "500 citation i", :engine_class => "light jet", :weight => 9502, :height => 157, :wingspan => 528, :length => 516})
	cessna550 = Airplane.find_or_create_by({ :manufacturer => "cessna", :model => "550 citation ii", :engine_class => "light jet", :weight => 13300, :height => 180, :wingspan => 626, :length => 567})
	
	# changed to medium and heavy jet for testing purposes
	cessna550Bravo = Airplane.find_or_create_by({ :manufacturer => "cessna", :model => "550 citation bravo", :engine_class => "midsize jet", :weight => 14800, :height => 180, :wingspan => 626, :length => 566})
	cessna560Ultra = Airplane.find_or_create_by({ :manufacturer => "cessna", :model => "560 citation ultra", :engine_class => "heavy jet", :weight => 16630, :height => 182, :wingspan => 649, :length => 587})
end

def addAirplanes(filename)
	airplaneTypes = File.open(Rails.root.join("db", "seed_data", filename))
	airplaneTypes.each do |curPlane|
		curPlane = curPlane.strip.downcase
		manufacturer, country, planeModel, planeClass, numCrew, numPassengers, engineType, range, emptyWeight, maxWeight, wingspan, wingArea, length, height = curPlane.split("\t")

		if !engineType =~ /[0-9]+/
			puts engineType
		end

		maxWeight = maxWeight.to_i

		next unless engineType =~ /[0-9]+/
		numEngines = engineType.match(/[0-9]+/)[0].to_i
		engineType = engineType.gsub(/[0-9]/, "").strip
		engineCategory = nil
# multi engines
		if numEngines > 1 
			if engineType =~ /piston/ # done
				if maxWeight > 8000
					engineCategory = "piston multi heavy"
				else
					engineCategory = "piston multi light"	
				end
			elsif engineType =~ /turboprop/ # done
				if maxWeight > 15000
					engineCategory = "turboprop twin heavy"
				elsif maxWeight > 11000
					engineCategory = "turboprop twin medium"
				else
					engineCategory = "turboprop twin light"
				end
					
			elsif engineType =~ /turbofan/
				if maxWeight > 40000
					engineCategory = "heavy jet"
				elsif maxWeight > 35000
					engineCategory = "super midsize jet"
				elsif maxWeight > 12500
					engineCategory = "midsize jet"
				else
					engineCategory = "light jet"
				end

			elsif engineType =~ /turbojet/ # I never see these
				engineCategory = "turbojet"
			elsif engineType =~ /radial/ # I never see these
				engineCategory = "radial multi"
			elsif engineType =~ /turboshaft/ # helicopters
				engineCategory = "turboshaft multi"			
			elsif engineType =~ /propfan/ # I never see these
				engineCategory = "propfan multi"	
			elsif engineType =~ /rotary/ # I never see these
				engineCategory = "rotary multi"
			elsif engineType =~ /rocket/ # I never see these... woosh!
				engineCategory = "rocket multi"
			end

# single engines
		elsif numEngines == 1
			if engineType =~ /piston/
				engineCategory = "piston single" # done
			elsif engineType =~ /turboprop/
				if maxWeight > 7500
					engineCategory = "turboprop single heavy"
				else
					engineCategory = "turboprop single light"
				end
			elsif engineType =~ /turbofan/ # done
				engineCategory = "midsize jet"

			elsif engineType =~ /turbojet/ # The majority of these are military
				engineCategory = "turbojet"
			elsif engineType =~ /radial/ # I never see these
				engineCategory = "radial single"
			elsif engineType =~ /turboshaft/ # helicopters
				engineCategory = "helicopter light"
			elsif engineType =~ /propfan/ # I never see these
				engineCategory = "propfan single"
			elsif engineType =~ /rotary/ # I never see these
				engineCategory = "rotary single"
			elsif engineType =~ /rocket/ # I never see these... woosh!
				engineCategory = "rocket single"
			end
		end

# Test for stuff that is nil. Find_or_create_by causes duplicates whenever there is a nil value being saved.
		if engineType.nil? or engineType.length == 0
			engineType = "nan"
		end
		if height.nil? or height.length == 0
			height = -1
		end
		if wingspan.nil? or wingspan.length == 0
			wingspan = -1
		end	
		if emptyWeight.nil? or emptyWeight.length == 0
			emptyWeight = -1
		end
		if numPassengers.nil? or numPassengers.length == 0
			numPassengers = -1
		end
		if range.nil? or range.length == 0
			range = -1
		end
		if wingArea.nil? or wingArea.length == 0
			wingArea = -1
		end

		Airplane.find_or_create_by({ :model => planeModel, :engine_class => engineCategory, :empty_weight => emptyWeight, :weight => maxWeight, :height => height, :wingspan => wingspan, :length => length, :manufacturer => manufacturer, :country => country, :plane_class => planeClass, :num_crew => numCrew, :num_passengers => numPassengers, :range => range, :wing_area => wingArea })
	end
end

def addFeeTypes(filename)
	feeTypes = File.open(Rails.root.join("db", "seed_data", filename))
	feeTypes.each do |curFeeType|
		FeeType.find_or_create_by({ :fee_type_description => curFeeType.strip })
	end
end

def addClassifications(filename)
	classificationTypes = File.open(Rails.root.join("db", "seed_data", filename))
	classificationTypes.each do |curClassificationType|
		Classification.find_or_create_by({ :classification_description => curClassificationType.strip })
	end
end

def addCategories(filename)
	categoryTypes = File.open(Rails.root.join("db", "seed_data", filename))
	categoryTypes.each do |curCategoryType|
		Category.find_or_create_by( :category_description => curCategoryType.strip )
	end
end

def addCities(filename)
	cities = File.open(Rails.root.join("db", "seed_data", filename))
	cities.each do |curCity|
		curCity = curCity.strip.downcase
		cityName, cityNameAscii, stateCode, stateName, countyName, countyFips, latitude, longitude, population, source, id = curCity.split(",")
		City.find_or_create_by({ :name => cityName, :state => stateCode, :latitude => latitude, :longitude => longitude })
	end
end

def addAirports(filename)
	airports = File.open(Rails.root.join("db", "seed_data", filename))
	airports.each do |curAirport|
		curAirport = curAirport.strip.downcase
		airportCode, airportName, ownerPhone, managerPhone, latitude, longitude, state, city = curAirport.split("\t")

		next if state != "il" and state != "oh" and state != "mn" and state != "mi" and state != "in" and state != "az" and state != "co" and state != "ky" and state != "mo" and state != "ms" and state!= "nv" and state != "ok" and state != "or" and state != "tx" and state != "ut" and state != "wa" and state != "wv"

		curCity = City.find_by({ :name => city, :state => state })
# this will create a city if it's not found, but because we don't actually care about the city, it doesn't matter much, and commenting this out avoids duplicates
		if curCity.nil?
			curCity = City.find_or_create_by({ :name => city, :state => state, :latitude => latitude, :longitude => longitude })
		end
		if curCity.nil?
			airports = Airport.find_or_create_by({ :airport_code => airportCode, :name => airportName.strip.downcase, :latitude => latitude, :longitude => longitude, :state => state, :ownerPhone => ownerPhone, :managerPhone => managerPhone})
		else
			airports = Airport.find_or_create_by({ :airport_code => airportCode, :name => airportName.strip.downcase, :latitude => latitude, :longitude => longitude, :state => state, :ownerPhone => ownerPhone, :managerPhone => managerPhone, :city => curCity })
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

		if state != "il" and state != "oh" and state != "mn" and state != "mi" and state != "in" and state != "az" and state != "co" and state != "ky" and state != "mo" and state != "ms" and state!= "nv" and state != "ok" and state != "or" and state != "tx" and state != "ut" and state != "wa" and state != "wv"
			return
		end

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
			Fbo.find_or_create_by({ :name => fboName, :phone => phone1, :alternate_phone => phone2, :airport => curAirport })
		end
	end
end

def addFeeFolder(folderName)
	folderPath = Rails.root.join("db", "seed_data", folderName)
	Dir.foreach(folderPath) do |curFile|
	  next if curFile == '.' or curFile == '..' # do work on real items
	  filePath = Rails.root.join("db", "seed_data", "call_sheets", curFile)
	  addFeesAndUpdateFbos(filePath)
	end
end

def addFeesAndUpdateFbos(filename)

	responseText = open(Rails.root.join("db", "seed_data", filename)).read
	responseText.each_line do |curRow|
		curRow = curRow.strip.downcase # get rid of new lines and make everything lowercase

		# split the excel sheet into individual variables using split

		state, city, airportName, airportCode, fboName, phoneNumbers, hasFees, classificationDesc, otherClassification, landingFee, rampFee, tieDownFee, facilityFee, callOutFee, hangarFee, otherFee, changeFrequency, feesWaived, fuelNeeded, contactPerson, callDate, infoQuality, hasFeeSheet, feeSheetLink, additionalInfo  = curRow.split("\t")

		next if hasFees == "did not/would not answer"

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
			if !hasFees.nil? and hasFees.strip == "no"
				curFbo.update( :classification => Classification.find_by( :classification_description => "flat rate"))
				FeeType.find_each do |curFeeType|
					if curFeeType.fee_type_description == "call out"
						singleFeeHelper(callOutFee, curFbo, curFeeType.fee_type_description)
					elsif curFeeType.fee_type_description == "hangar"
						# do nothing
					else
						singleFeeHelper("0", curFbo, curFeeType.fee_type_description)
					end
				end
			elsif feeClassification.nil?
				#puts curFbo.name
				# do nothing
			else
				curFbo.update( :classification => feeClassification )
				
				landingFee.split(",").each do |curFee|
					singleFeeHelper(curFee, curFbo, "landing")
				end
				rampFee.split(",").each do |curFee|
					singleFeeHelper(curFee, curFbo, "ramp")
				end	
				tieDownFee.split(",").each do |curFee|
					singleFeeHelper(curFee, curFbo, "tie down")
				end
				facilityFee.split(",").each do |curFee|
					singleFeeHelper(curFee, curFbo, "facility")
				end		
				callOutFee.split(",").each do |curFee|
					singleFeeHelper(curFee, curFbo, "call out")
				end
			end
=begin
			else classificationDesc == "flat rate"
				curCategory = Category.find_by( :category_description => "flat rate")
				curFbo.update( :classification => feeClassification )
				
				landingFee.split(",").each do |curFee|
					singleFeeHelper(curFee, curCategory, curFbo, "landing")
				end
				rampFee.split(",").each do |curFee|
					singleFeeHelper(curFee, curCategory, curFbo, "ramp")
				end	
				tieDownFee.split(",").each do |curFee|
					singleFeeHelper(curFee, curCategory, curFbo, "tie down")
				end
				facilityFee.split(",").each do |curFee|
					singleFeeHelper(curFee, curCategory, curFbo, "facility")
				end		
				callOutFee.split(",").each do |curFee|
					singleFeeHelper(curFee, curCategory, curFbo, "call out")
				end
			end
			
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
=end

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
			curFbo = Fbo.find_or_create_by( :name => fboName, :airport => curAirport, :classification => feeClassification )
	# If the FBO has no fees
			if hasFees.strip == "no"
				curCategory = Category.find_by( :category_description => "no fee")
				FeeType.find_each do |curFeeType|
					if curFeeType.fee_type_description == "call out"
						singleFeeHelper(callOutFee, curFbo, curFeeType.fee_type_description)
					elsif curFeeType.fee_type_description == "hangar"
						# do nothing
					else
						singleFeeHelper("0", curFbo, curFeeType.fee_type_description)
						#Fee.find_or_create_by( :fee_type => curFeeType, :fbo => curFbo, :category => curCategory, :price => 0)
					end
				end
			elsif feeClassification.nil? or classificationDesc == ""
				# do nothing
			else

				if !landingFee.nil?
					landingFee.split(",").each do |curFee|
						singleFeeHelper(curFee, curFbo, "landing")
					end
				end

				if !rampFee.nil?
					rampFee.split(",").each do |curFee|
						singleFeeHelper(curFee, curFbo, "ramp")
					end	
				end

				if !tieDownFee.nil?
					tieDownFee.split(",").each do |curFee|
						singleFeeHelper(curFee, curFbo, "tie down")
					end
				end

				if !facilityFee.nil?
					facilityFee.split(",").each do |curFee|
						singleFeeHelper(curFee, curFbo, "facility")
					end		
				end

				if !callOutFee.nil?
					callOutFee.split(",").each do |curFee|
						singleFeeHelper(curFee, curFbo, "call out")
					end
				end
			end

=begin
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
=end

		else
			#puts fboName
		end
	end
end

main










