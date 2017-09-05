module SeedsHelper

	def addWeightFee(feeList, fbo, feeTypeDescription)
		feeList.split(",").each do |curFee|
			if curFee =~ /^([0-9]+-[0-9]+: ?[0-9]+)/
				curFee = curFee.match(/^([0-9]+-[0-9]+: ?[0-9]+)/)[0] # get the fee for the current category
				feePrice = curFee.match(/[0-9]{1,4}/)[0] # narrow it down to just the fee itself
				if curFee =~ /[a-z ]+/
					categoryDesc = curFee.match(/[a-z ]+/)[0].strip # grab the category description as well
				end
			end
		end
	end

	def getTieDownFee(rampFee)
		# Tie down fees are listed under ramp fee because we didn't make a column for it in the spreadsheet.
		# this method separates the tie down fee from the ramp fee.
		tieDownFee = ""
		# the length check is to ignore the tie down fees that are tie down: single engine: 10, for example, because those are hard and I don't want to do them.
		if rampFee.include?("tie down")
			# look for a tie down fee
			tieDownFee = rampFee.match(/tie down: ?[0-9]+/)
			# was a tie down fee found?
			if tieDownFee != nil
				# if one was found, pull the match from the ramp fee
				tieDownFee = tieDownFee[0]
				# remove the tie down text so just the number and category is left
				tieDownFee = tieDownFee.gsub(/tie down: /, "")
				# remove the tie down fee from the ramp fee
				# BUG! doesn't account for tie down fees of the format tiedown: single engine: XX
				rampFee = rampFee.gsub(/,?tie down: ?[0-9]+/, "")
				#puts tieDownFee


				# I don't think these are actually needed but I don't want to delete them in case they are.
				#if rampFee != nil
				#	rampFee = rampFee[0]
				#end
			end
		end
		return [rampFee, tieDownFee]
	end

	def singleFeeHelper(feePrice, category, fbo, feeType)
		if feePrice =~ /$?[0-9]+\/[a-z]|/
			
		end
		feePrice = feeToNumber(feePrice)
		feeType = FeeType.find_by( :fee_type_description => feeType )
		if !feeType.nil?
			Fee.create(:fee_type_id => feeType.id, :category => category, :fbo => fbo, :price => feePrice)
			#puts fbo.name + ": " + feeType.fee_type_description + ": " + category.category_description + ": " + feePrice.to_s
		end
	end

	def feeToNumber(fee)

		# If the fee is already an integer, nothing needs to happen
		if fee.class == Fixnum
			return fee

		# If the fee isn't there, just return 0.
		elsif fee.nil? or fee.length == 0
			return 0

		# If the fee is already an integer, nothing needs to happen
		elsif fee.class == Fixnum
			return fee

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
		if !feeList.nil?
			feeList.split(",").each do |curFee|
				if curFee =~ /^([a-z ]+:[ $]+?[0-9]+)/
					curFee = curFee.match(/^([a-z ]+:[ $]+?[0-9]+)/)[0] # get the fee for the current category
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

					when "twin engine turboprop", "turboprop twin medium"
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

				# If a fee is 0
				elsif curFee =~ /[none|no|0]/ or curFee.nil? or curFee == ""
					category = Category.find_by( :category_description => "no fee" )
					singleFeeHelper(0, category, fbo, feeTypeDescription)

				# If there is a flat rate stuck somewhere in there	
				elsif curFee =~ /[0-9]+/
					feePrice = curFee.match(/[0-9]+/)[0]
					category = Category.find_by( :category_description => "flat rate" )
					singleFeeHelper(feePrice, category, fbo, feeTypeDescription)

				else
					puts curFee # if this happens, I'd like to know what didn't go through
				end
			end
		end
	end

	def addFeeByWeight(feeList, fbo, feeTypeDescription)
		feeList.split(",").each do |curFee|
			if curFee =~ /^[0-9.]+ ?per [0-9]+ ?[a-z]+/
				curFee = curFee.match(/^[0-9.]+ ?per [0-9]+ ?[a-z]+/)[0] # get the fee for the current category
				unitPrice = curFee.match(/[0-9.]+/)[1] # narrow it down to just the fee itself
				unitMagnitude = curFee.match(/[0-9.]+/)[2]
				unitPrice = feeToNumber(unitPrice)
				unitMagnitude = feeToNumber(unitMagnitude)

				feeType = FeeType.find_by( :fee_type_description => feeTypeDescription)

				Fee.create( :fee_type => feeType, :fbo => fbo, :category => Category.find_by( :category_description => "weight" ),
					:unit_price => unitPrice, :unit_magnitude => unitMagnitude)
			end
		end		
	end

end