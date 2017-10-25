include SeedsHelper # located at lib/seeds_helper.rb

def main
# Delete stuff. This is commented out because deleting generally shouldn't be a thing that happens. It changes the IDs of everything and breaks references.
# The reason we don't need it is because database entries use the find_or_creaty_by method which checks if an entry exists before adding it.

# TODO
# Some data in the database needs to change, so I'll need to be careful about how I do that or some people will have to reset their profiles.
# TODO

	Fee.delete_all
=begin
	Category.delete_all

	Fbo.delete_all
	Airport.delete_all
	City.delete_all

	Airplane.delete_all

	FeeType.delete_all
	Classification.delete_all
=end

# Add stuff	

# Add airplane data
	#addAirplanes("airplane_seed_data")

# Add fee type data.
	#addFeeTypes("fee_types")

# Add classification data
	#addClassifications("classification_types")

# Add category data
	#addCategories("categories")

# NOT CURRENTLTY USED. Add city data
# This is curently not used because having a lot of cities in the database makes the website run slowly.
# It's weird though, because it's not just queries that are slow, the entire thing is.
	#addCities("uscitiesv1.3.csv")

#	Add airport data
	#addAirports("full_airport_data")

# Add FBO data. This has to come after airports because FBOs make a reference to airports.
	#addFboFolder("fbo_call_data")
	updateFboEmails("fbo_email_data_2")

# NOT CURRENTLY USED. This is the method to add fees from a single file. It can be used for testing
	#addFees(Rails.root.join("db", "seed_data", "call_sheets", "tx_call_sheet.tsv"))

# Add fee information from the call sheets. This has references to most other tables, so it has to come last.
	addFeeFolder("call_sheets")

# Add fee information from the fee sheets we got.
	addFeeFolder("fbo_fee_sheets")

# Add startup data information. The call sheet was different back then.
	addStartupTermData("survey_responses.tsv")

# TODO addFbos and addStartupTermData both add FBOs to the database, figure it out. Solution was to remove the fbos from states that we covered during startup term.
end

def addAirplanes(filename)
	# Open the airplane file, which is saved as a tsv where each tab represents a different piece of data for a plane, and each line represents a different plane.
	airplaneTypes = File.open(Rails.root.join("db", "seed_data", filename))

	# Iterate through each line
	airplaneTypes.each do |curPlane|
		# Strip and downcase each plane to get ensure a consistent format
		curPlane = curPlane.strip.downcase

		# split by tabs to get each piece of data
		manufacturer, country, planeModel, planeClass, numCrew, numPassengers, engineType, range, emptyWeight, maxWeight, wingspan, wingArea, length, height = curPlane.split("\t")

		# each engine type should have the number of engines and the type of engine. If not, print the one that didn't have the info, and go to the next plane.
		if !engineType =~ /[0-9]+/
			printf("missing engine info: %s - %s", planeModel, engineType)
			next
			print("this should never print")
		end

		# I'm puttling from a text file, so the weights are in a string format. Convert to ints.
		# If the max weight is nil, just move on to the next plane. The empty weight isn't really important so we can do without it.
		if !maxWeight.nil?
			maxWeight = maxWeight.to_i
		else
			next
		end

		if !emptyWeight.nil?
			emptyWeight = emptyWeight.to_i
		end

		# The engine type variable has the number of engines and the type of engine. The number of engines is just a number, so I just have to grab the number
		# The engine type is anything that isn't a number, so I just remove all numbers from the string, then strip to get rid of extra whitespace
		numEngines = engineType.match(/[0-9]+/)[0].to_i
		engineType = engineType.gsub(/[0-9]+/, "").strip
		engineCategory = nil

		# turbofan engines (AKA jets). The number of engines doesn't actually matter for jets, so handle their case first
		# There are 6 types of jet: super heavy jet, heavy jet, super midsize jet, midsize jet, light jet, and very light jet.
		# The current code only has 4 of those, they should be pretty obvious.
		# There are a total of 255 jets, 162 are heavy jets, 13 are super midsize jets, 61 are midsize jets, and 19 are light jets
		# It's hard to tell what the real ratios are though, because there are some militarty jets and airliners in there.
		if engineType =~ /turbofan/
			if maxWeight > 40000
					engineCategory = "heavy jet"
			elsif maxWeight > 35000
					engineCategory = "super midsize jet"
			elsif maxWeight > 12500
					engineCategory = "midsize jet"
			else
					engineCategory = "light jet"
			end

		# For everything else, the number of engines matter
		# Multi engines first
		elsif numEngines > 1 
			# Piston engines. As of now, there are only two types of multi piston engine: heavy and light.
			# I split them at 8000 lbs. That gives 26/65 piston multis being heavy, and 39/65 being light.
			if engineType =~ /piston/
				if maxWeight > 8000
					engineCategory = "piston multi heavy"
				else
					engineCategory = "piston multi light"	
				end
			# Turboprop engines. I haven't seen any turboprop that has more than 2 engines, and Rod also does turboprops as twins.
			# As of now, there are 3 of these. turboprop heavy, medium, and light. 
			# Anything greater than 15000 is a heavy turboprop, between 11000 and 15000 is medium, and less is light.
			# There are 82 heavies, 30 mediums, and 12 lights. That should probably be adjusted.
			elsif engineType =~ /turboprop/
				if maxWeight > 15000
					engineCategory = "turboprop twin heavy"
				elsif maxWeight > 11000
					engineCategory = "turboprop twin medium"
				else
					engineCategory = "turboprop twin light"
				end

			# These types of engine are practically never used by general aviation. They're in the database anyway.
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
				# There's only one type of piston single at the moment.
				# This will need to be split up into small and large in the future.
				engineCategory = "piston single"
			elsif engineType =~ /turboprop/
				# a single engine turboprop is heavy if they weigh more than 7500 lbs, and light otherwise
				# there are 10 turboprop single heavies and 16 turboprop single lights
				if maxWeight > 7500
					engineCategory = "turboprop single heavy"
				else
					engineCategory = "turboprop single light"
				end

			# These types of engines are almost never used in general aviation. They're in the database anyway.
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

# Test for stuff that is nil. Find_or_create_by is creating duplicates. I think it happends whenever there is a nil value being saved.
# My solution is to set nil integers to -1 and nil strings "nil". It fixed the problem, but I need to adjust the fee retrieval method.
		if engineType.nil? or engineType.length == 0
			engineType = "nan"
		end
		if height.nil? or height.length == 0
			height = -1
		end
		if wingspan.nil? or wingspan.length == 0
			wingspan = -1
		end	
		if emptyWeight.nil?
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

		# Create the airplane using the characteristics found in the method.
		Airplane.find_or_create_by({ :model => planeModel, :engine_class => engineCategory, :empty_weight => emptyWeight, :weight => maxWeight, :height => height, :wingspan => wingspan, :length => length, :manufacturer => manufacturer, :country => country, :plane_class => planeClass, :num_crew => numCrew, :num_passengers => numPassengers, :range => range, :wing_area => wingArea })
	end
end

# Adds the fee types (ie: landing, tie down)
def addFeeTypes(filename)
	# open the file with fee types
	feeTypes = File.open(Rails.root.join("db", "seed_data", filename))
	# Each line of the file contains a fee types description. Iterate through the file and create a fee type for each line.
	feeTypes.each do |curFeeType|
		FeeType.find_or_create_by({ :fee_type_description => curFeeType.strip })
	end
end

# Adds the classifications (ie: weight, engine type)
def addClassifications(filename)
	# open the file with classifications
	classificationTypes = File.open(Rails.root.join("db", "seed_data", filename))
	# Each line of the file contains a classification description. Iterate through the file and create a classification for each line.
	classificationTypes.each do |curClassificationType|
		Classification.find_or_create_by({ :classification_description => curClassificationType.strip })
	end
end

# Adds the categories (ie: piston single)
def addCategories(filename)
	# Open the file with categories
	categoryTypes = File.open(Rails.root.join("db", "seed_data", filename))
	# Each line of the file contains a category description. Iterate through the file and create a classification for each line.
	categoryTypes.each do |curCategoryType|
		Category.find_or_create_by( :category_description => curCategoryType.strip )
	end
end

# Adds the cities
def addCities(filename)
	cities = File.open(Rails.root.join("db", "seed_data", filename))
	# Iterate through each line of the file.
	cities.each do |curCity|
		# strip and downcase each line to ensure a consistent format
		curCity = curCity.strip.downcase
		# Data is separated by commas, so use the split method with commas to get each piece of data
		cityName, cityNameAscii, stateCode, stateName, countyName, countyFips, latitude, longitude, population, source, id = curCity.split(",")
		City.find_or_create_by({ :name => cityName, :state => stateCode, :latitude => latitude, :longitude => longitude })
	end
end

# Adds the airports
def addAirports(filename)
	# Open the file with airports
	airports = File.open(Rails.root.join("db", "seed_data", filename))

	airports.each do |curAirport|
		# strip and downcase each line to ensure a consistent format
		curAirport = curAirport.strip.downcase
		# Data is separated by tabs, so use the split method with tabs to get each piece of data
		airportCode, airportName, ownerPhone, managerPhone, latitude, longitude, state, city = curAirport.split("\t")

		# These are the states we have, ignore anything else for now. Make sure to add states as they come in.
		next if state != "il" and state != "oh" and state != "mn" and state != "mi" and state != "in" and state != "az" and state != "co" and state != "ky" and state != "mo" and state != "ms" and state!= "nv" and state != "ok" and state != "or" and state != "tx" and state != "ut" and state != "wa" and state != "wv"

		# Airports have a reference to a city, so we need that info. First, try to find the city by the city and state
		curCity = City.find_by({ :name => city, :state => state })

		# Create a city if it's not found
		if curCity.nil?
			curCity = City.find_or_create_by({ :name => city, :state => state, :latitude => latitude, :longitude => longitude })
		end

		# If the city is somehow nil still, create the airport anyway, but without the city id
		if curCity.nil?
			airports = Airport.find_or_create_by({ :airport_code => airportCode, :name => airportName.strip.downcase, :latitude => latitude, :longitude => longitude, :state => state, :ownerPhone => ownerPhone, :managerPhone => managerPhone})
		# If the city is found, we can just make the airport with the data we grabbed
		else
			airports = Airport.find_or_create_by({ :airport_code => airportCode, :name => airportName.strip.downcase, :latitude => latitude, :longitude => longitude, :state => state, :ownerPhone => ownerPhone, :managerPhone => managerPhone, :city => curCity })
		end
	end
end

# Add every FBO in a folder to the database.
# This method iterates through every file in the FBO folder, and calls the fbo adding function on them.
def addFboFolder(folderName)
	# get the filepath of the folder
	folderPath = Rails.root.join("db", "seed_data", folderName)
	# for each file in the folder
	Dir.foreach(folderPath) do |curFile|
		# I'm not entirely sure why this line is necessary, but it was in the stack overflow thing I copied. Apparently it skips over things that aren't actually files
	  next if curFile == '.' or curFile == '..' # do work on real items
	  # Get the path of the current file
	  filePath = Rails.root.join("db", "seed_data", "fbo_call_data", curFile)
	  # call the fbo adding method
	  addFbos(filePath)
	end
end

# Add every fbo in a file to the database

# I can't just redo the FBO table because then all of our references would get screwed up. But the way this method works misses a lot of FBOs
def updateFboEmails(folderName)
	folderPath = Rails.root.join("db", "seed_data", folderName)
	count = 0
	Dir.foreach(folderPath) do |curFile|
		next if curFile == '.' or curFile == '..' # do work on real items
		filePath = Rails.root.join("db", "seed_data", folderName, curFile)
		fbos = open(filePath).read
		fbos.each_line do |curFbo|
			curFbo = curFbo.strip.downcase
			state, cityName, airportName, airportCode, fboName, phoneNumbers, email, numOperations = curFbo.split("\t")

			if state != "il" and state != "oh" and state != "mn" and state != "mi" and state != "in" and state != "az" and state != "co" and state != "ky" and state != "mo" and state != "ms" and state!= "nv" and state != "ok" and state != "or" and state != "tx" and state != "ut" and state != "wa" and state != "wv"
				break
			end
			
			phone1 = phoneNumbers.split(",")[0]
			phone2 = phoneNumbers.split(",")[1]

			if phone2.nil?
				phone2 = ""
			end

			curAirport = Airport.find_by( :airport_code => airportCode )
			if curAirport.nil?
				curAirport = Airport.find_by( :name => airportName, :state => state )
			end

			if curAirport.nil?
				#puts airportName
			else
				databaseFbo = Fbo.find_by( :airport => curAirport, :name => fboName)
				if databaseFbo.nil?
					databaseFbo = Fbo.find_by( :airport => curAirport, :phone => phone1 )
					if databaseFbo.nil?
						if databaseFbo.nil?
							databaseFbo = Fbo.find_by( :airport => curAirport )
							if databaseFbo.nil?
								count += 1
								#printf("%s\t%s\t%s\n", state, fboName, airportName)
							end
						end
					end
				end
			end

			#databaseFbo = Fbo.find_by( :name => fboName, :phone => phone1, :alternate_phone => phone2 )
			if databaseFbo.nil?
				#printf("%s\t%s\t%s\n", state, fboName, airportName)
			else
				databaseFbo.update( :email => email )
			end
		end
	end
	puts count
end

def addFbos(filePath)
	# open the file
	fbos = open(filePath).read
	
	# Each line of the file contains information about an info. Iterate through each one.
	fbos.each_line do |curFbo|
		# strip and downcase each line to ensure a consistent format.
		curFbo = curFbo.strip.downcase

		# The data is tab separated, so splitting by tabs will get each individual piece of data.
		state, city, airportName, airportCode, fboName, phone = curFbo.split("\t")

		# These are the states we have data for. If we encounter a state that we don't have data for, return.
		if state != "il" and state != "oh" and state != "mn" and state != "mi" and state != "in" and state != "az" and state != "co" and state != "ky" and state != "mo" and state != "ms" and state!= "nv" and state != "ok" and state != "or" and state != "tx" and state != "ut" and state != "wa" and state != "wv"
			return
		end

		# an FBO can have either 1 or 2 phone numbers. If there are two, they're separated by a comma, so use the split method to separate them.
		phone1 = phone.split(", ")[0]
		phone2 = phone.split(", ")[1]

		# If there is only 1 phone number, set the second one to an empty string.
		if phone2.nil?
			phone2 = ""
		end

		# Try to find the airport by the name and state

		curAirport = Airport.find_by(:name => airportName, :state => state)

		# If it wasn't found, look using the airport code.
		if curAirport.nil?
			curAirport = Airport.find_by(:airport_code => airportCode)
		end

		# If the airport was found, add the FBO using the data we pulled.
		# If the city wasn't found, then having an FBO with no city is pretty useless so ignore it.
		if !curAirport.nil?
			Fbo.find_or_create_by({ :name => fboName, :phone => phone1, :alternate_phone => phone2, :airport => curAirport })
		end
	end
end

# Add the info from every call sheet to the database.
def addFeeFolder(folderName)
	folderPath = Rails.root.join("db", "seed_data", folderName)
	# Iterate through each line of the file.
	Dir.foreach(folderPath) do |curFile|
		# I'm not entirely sure why this line is necessary, but it was in the stack overflow thing I copied. Apparently it skips over things that aren't actually files
	  next if curFile == '.' or curFile == '..' # do work on real items
	  # Get the file path
	  filePath = Rails.root.join("db", "seed_data", "call_sheets", curFile)
	  # Call the fee adding method on the file
	  addFees(filePath)
	end
end

# Add every fee in a specific call sheet to the database.
def addFees(filename)
	responseText = open(Rails.root.join("db", "seed_data", filename)).read
	responseText.each_line do |curRow|
		curRow = curRow.strip.downcase # get rid of new lines and make everything lowercase

		# split the excel sheet into individual variables using split
		# Note that each fee is itself a list of fees separated by commas.
		state, city, airportName, airportCode, fboName, phoneNumbers, hasFees, classificationDesc, otherClassification, landingFee, rampFee, tieDownFee, facilityFee, callOutFee, hangarFee, otherFee, changeFrequency, feesWaived, fuelNeeded, contactPerson, callDate, infoQuality, hasFeeSheet, feeSheetLink, additionalInfo  = curRow.split("\t")
		# If the FBO didn't or wouldn't answer, then we have no data for them and we should skip forward
		next if hasFees == "did not/would not answer"

		#feeClassification = Classification.find_by( :classification_description => classificationDesc )

		curAirport = Airport.find_by( :name => airportName)
		if curAirport.nil?
			curAirport = Airport.find_by( :airport_code => airportCode )
			# If the airport wasn't found, try adding a k to the front of the airport code and try again
			if curAirport.nil? and airportCode.length == 3
				newCode = "k" + airportCode
				curAirport = Airport.find_by( :airport_code => newCode )
			elsif curAirport.nil? and airportCode.length == 4
			# If the airport wasn't found, try removing the k from the front and trying again
				newCode = airportCode[1..3]
				curAirport = Airport.find_by( :airport_code => newCode )
			end
		end

# I guess hypothetically this wouldn't work if there were two FBOs at an airport with the same name, but I don't think that has ever happened yet.
		curFbo = Fbo.find_by(:name => fboName, :airport => curAirport)

		if !curFbo.nil?
			# this is what should happen
			if !hasFees.nil? and hasFees.strip == "no"
				#curFbo.update( :classification => Classification.find_by( :classification_description => "flat rate"))
				FeeType.find_each do |curFeeType|
					if curFeeType.fee_type_description == "call out"
						singleFeeHelper(callOutFee, curFbo, curFeeType.fee_type_description, "flat rate")
					elsif curFeeType.fee_type_description == "hangar"
						# do nothing
					else
						singleFeeHelper("0", curFbo, curFeeType.fee_type_description, "flat rate")
					end
				end
			#elsif feeClassification.nil?
				#puts curFbo.name
				# do nothing

			# If the FBO has fees, so most of the time.
			else
				#curFbo.update( :classification => feeClassification )
				
				# For each type of fee, if it isn't nil, the split it up into its individual fees, then call the fee helper method on those fees.
				# landing fees
				if !landingFee.nil?
					landingFee.split(",").each do |curFee|
						singleFeeHelper(curFee, curFbo, "landing", classificationDesc)
					end
				end

				# ramp fees
				if !rampFee.nil?
					rampFee.split(",").each do |curFee|
						singleFeeHelper(curFee, curFbo, "ramp", classificationDesc)
					end	
				end

				# tie down fees
				if !tieDownFee.nil?
					tieDownFee.split(",").each do |curFee|
						singleFeeHelper(curFee, curFbo, "tie down", classificationDesc)
					end
				end

				# facility fees
				if !facilityFee.nil?
					facilityFee.split(",").each do |curFee|
						singleFeeHelper(curFee, curFbo, "facility", classificationDesc)
					end	
				end	

				# call out fees
				if !callOutFee.nil?
					callOutFee.split(",").each do |curFee|
						singleFeeHelper(curFee, curFbo, "call out", classificationDesc)
					end
				end
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
			#curFbo = Fbo.find_or_create_by( :name => fboName, :airport => curAirport, :classification => feeClassification )
			curFbo = Fbo.find_or_create_by( :name => fboName, :airport => curAirport)
	# If the FBO has no fees
			if hasFees.strip == "no"
				curCategory = Category.find_by( :category_description => "flat rate")
				FeeType.find_each do |curFeeType|
					if curFeeType.fee_type_description == "call out"
						singleFeeHelper(callOutFee, curFbo, curFeeType.fee_type_description, "flat rate")
					elsif curFeeType.fee_type_description == "hangar"
						# do nothing
					else
						singleFeeHelper("0", curFbo, curFeeType.fee_type_description, "flat rate")
						#Fee.find_or_create_by( :fee_type => curFeeType, :fbo => curFbo, :category => curCategory, :price => 0)
					end
				end
			elsif feeClassification.nil? or classificationDesc == ""
				# do nothing
			else

				if !landingFee.nil?
					landingFee.split(",").each do |curFee|
						singleFeeHelper(curFee, curFbo, "landing", classificationDesc)
					end
				end

				if !rampFee.nil?
					rampFee.split(",").each do |curFee|
						singleFeeHelper(curFee, curFbo, "ramp", classificationDesc)
					end	
				end

				if !tieDownFee.nil?
					tieDownFee.split(",").each do |curFee|
						singleFeeHelper(curFee, curFbo, "tie down", classificationDesc)
					end
				end

				if !facilityFee.nil?
					facilityFee.split(",").each do |curFee|
						singleFeeHelper(curFee, curFbo, "facility", classificationDesc)
					end		
				end

				if !callOutFee.nil?
					callOutFee.split(",").each do |curFee|
						singleFeeHelper(curFee, curFbo, "call out", classificationDesc)
					end
				end
			end
		else
			#puts fboName
		end
	end
end

main










