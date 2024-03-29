require 'test_helper'

class FeesTest < ActionDispatch::IntegrationTest

	def setup
		@cessna172 = airplanes(:cessna172)
		@cessna425 = airplanes(:cessna425)
	end

	test "ensure correct foreign key relations" do
		# check that the fee is correct
		@jetAirLanding172 = fees(:jet_air_sep_landing)

		# check that I can grab the fbo from the fee
		jetAir = Fbo.find(@jetAirLanding172.fbo_id)
		assert_equal(fbos(:jet_air).name, jetAir.name)

		# check that I can grab the fee type from the fee
		landingFee = FeeType.find(@jetAirLanding172.fee_type_id)
		assert_equal(fee_types(:landing).fee_type_description, landingFee.fee_type_description)

		# check that I can grab the category from the fee
		pistonSingle = Category.find(@jetAirLanding172.category_id)	
		assert_equal(categories(:piston_single).category_description, pistonSingle.category_description)

		# check that I can grab the airport from the FBO
		galesburgAirport = Airport.find(jetAir.airport_id)
		assert_equal(airports(:galesburg_airport).name, galesburgAirport.name)

		# check that I can grab the city from the airport
		galesburg = City.find(galesburgAirport.city_id)
		assert_equal(cities(:galesburg).name, galesburg.name)

	end

	test "multiple fee types retrievable" do
		@jetAir = fbos(:jet_air)
		curFees = getFees(@cessna172, @jetAir)
		targetFees = Fee.joins(:fbo).joins(:category).where('categories.category_description == "piston single" or categories.category_description == "flat rate" and fbos.name == "Jet Air, inc."')
		curFees.each do |curFee|
			assert_includes(targetFees, curFee)
		end
	end

	test "fee time unit retrievable" do
		@jetAir = fbos(:jet_air)

		targetFee = nil

		curFees = getFees(@cessna172, @jetAir, "day", 1)
		curFees.each do |curFee|
			if curFee.fee_type.fee_type_description == "tie down"
				targetFee = curFee
			end
		end

		assert_equal(4, targetFee.price)
		assert_equal("day", targetFee.time_unit)
	end

	test "engine type fees retrievable" do
		@jetAir = fbos(:jet_air)

		targetFee = nil

		curFees = getFees(@cessna172, @jetAir)
		curFees.each do |curFee|
			if curFee.fee_type.fee_type_description == "landing"
				targetFee = curFee
			end
		end
		assert_equal(fees(:jet_air_sep_landing).price, targetFee.price)

		curFees = getFees(@cessna425, @jetAir)
		curFees.each do |curFee|
			if curFee.fee_type.fee_type_description == "landing"
				targetFee = curFee
			end
		end
		assert_equal(fees(:jet_air_tet_landing).price, targetFee.price)
	end

	test "model fees retrievable" do
		@jetFlair = fbos(:jet_flair)

		targetFee = nil

		curFees = getFees(@cessna172, @jetFlair)
		curFees.each do |curFee|
			if curFee.fee_type.fee_type_description == "landing"
				targetFee = curFee
			end
		end
		assert_equal(fees(:jet_flair_172_landing).price, targetFee.price)

		curFees = getFees(@cessna425, @jetFlair)
		curFees.each do |curFee|
			if curFee.fee_type.fee_type_description == "landing"
				targetFee = curFee
			end
		end
		assert_equal(fees(:jet_flair_425_landing).price, targetFee.price)
	end

	test "no fees retrievable" do
		@noFeeFbo = fbos(:no_fee_fbo)

		targetFee = nil

		curFees = getFees(@cessna172, @noFeeFbo)
		curFees.each do |curFee|
			if curFee.fee_type.fee_type_description == "landing"
				targetFee = curFee
			end
		end
		assert_equal(0, targetFee.price)

		curFees = getFees(@cessna425, @noFeeFbo)
		curFees.each do |curFee|
			if curFee.fee_type.fee_type_description == "landing"
				targetFee = curFee
			end
		end
		assert_equal(0, targetFee.price)

	end

	test "flat rate fees retrievable" do
		@flatRateFbo = fbos(:flat_rate_fbo)

		targetFee = nil

		curFees = getFees(@cessna172, @flatRateFbo)
		curFees.each do |curFee|
			if curFee.fee_type.fee_type_description == "landing"
				targetFee = curFee
			end
		end
		assert_equal(fees(:flat_rate_fbo_landing).price, targetFee.price)

		curFees = getFees(@cessna425, @flatRateFbo)
		curFees.each do |curFee|
			if curFee.fee_type.fee_type_description == "landing"
				targetFee = curFee
			end
		end
		assert_equal(fees(:flat_rate_fbo_landing).price, targetFee.price)
	end

	test "weight range fees retrievable" do
		@weightRangeFbo = fbos(:weight_range_fbo)

		targetFee = nil

		curFees = getFees(@cessna172, @weightRangeFbo)
		curFees.each do |curFee|
			if curFee.fee_type.fee_type_description == "landing"
				targetFee = curFee
			end
		end		
		assert_equal(fees(:weight_range_fbo_small_landing).price, targetFee.price)

		curFees = getFees(@cessna425, @weightRangeFbo)
		curFees.each do |curFee|
			if curFee.fee_type.fee_type_description == "landing"
				targetFee = curFee
			end
		end	
		assert_equal(fees(:weight_range_fbo_medium_landing).price, targetFee.price)

	end
		
	test "weight fees retrievable with variable price" do
		@weightFbo = fbos(:weight_fbo)

		curFees = getFees(@cessna172, @weightFbo)

		curFees.each do |curFee|
			if curFee.fee_type.fee_type_description == "landing"
				assert_equal(22, curFee.price)
			end
		end

		curFees = getFees(@cessna425, @weightFbo)

		curFees.each do |curFee|
			if curFee.fee_type.fee_type_description == "landing"
				assert_equal(88, curFee.price)
			end
		end
	end

	test "weight fees retrievable with base and variable price" do
		@weightFbo = fbos(:weight_fbo)

		curFees = getFees(@cessna172, @weightFbo)

		curFees.each do |curFee|
			if curFee.fee_type.fee_type_description == "ramp"
				assert_equal(19, curFee.price)
			end
		end
	end

	test "multiple weight fee types retrievable" do
		@weightFbo = fbos(:weight_fbo)

		curFees = getFees(@cessna172, @weightFbo)

		curFees.each do |curFee|
			if curFee.fee_type.fee_type_description == "landing"
				assert_equal(22, curFee.price)
			elsif curFee.fee_type.fee_type_description == "ramp"
				assert_equal(19, curFee.price)
			end
		end
	end

	test "fees with time units retrievable" do
		@jetAir = fbos(:jet_air)

		targetFee = nil

		curFees = getFees(@cessna172, @jetAir, "hour", 4, nil)
		curFees.each do |curFee|
			if curFee.fee_type.fee_type_description == "call out"
				targetFee = curFee
			end
		end
		assert_equal(125, targetFee.price)

		curFees = getFees(@cessna172, @jetAir, "hour", 0, nil)
		curFees.each do |curFee|
			if curFee.fee_type.fee_type_description == "call out"
				targetFee = curFee
			end
		end
		assert_equal(50, targetFee.price)
	end

	test "fees with different prices at different times retrievable" do
		@signature = fbos(:signature)

		targetFee = nil

		curFees = getFees(@cessna172, @signature, nil, 0, "19:00".to_time)
		curFees.each do |curFee|
			if curFee.fee_type.fee_type_description == "call out"
				targetFee = curFee
			end
		end

		assert_equal(35, targetFee.price)

		curFees = getFees(@cessna172, @signature, nil, 0, "3:00".to_time)
		curFees.each do |curFee|
			if curFee.fee_type.fee_type_description == "call out"
				targetFee = curFee
			end
		end

		assert_equal(40, targetFee.price)
	end

	test "fees at incorrect times are not retrieved" do
		@signature = fbos(:signature)
		curFees = getFees(@cessna172, @signature, nil, 0, "14:00".to_time)

		targetFee = nil

		curFees.each do |curFee|
			if curFee.fee_type.fee_type_description == "call out"
				targetFee = curFee
			end
		end
		assert_nil(targetFee)
	end

	test "fees that are temporarily free" do
		@jetFlair = fbos(:jet_flair)
		curFees = getFees(@cessna172, @jetFlair, "day", 5, nil)

		targetFee = nil

		curFees.each do |curFee|
			if curFee.fee_type.fee_type_description == "tie down"
				targetFee = curFee
			end
		end
		assert_equal(12, targetFee.price)
	end

	test "consolidated categories" do
		@notSpecific = fbos(:not_specific_fbo)
		@cessna173 = airplanes(:cessna173)
		@cessna174 = airplanes(:cessna174)

		landing172 = nil
		curFees = getFees(@cessna172, @notSpecific)
		curFees.each do |curFee|
			if curFee.fee_type.fee_type_description == "landing"
				landing172 = curFee
			end
		end

		landing173 = nil
		curFees = getFees(@cessna173, @notSpecific)
		curFees.each do |curFee|
			if curFee.fee_type.fee_type_description == "landing"
				landing173 = curFee
			end
		end

		landing174 = nil
		curFees = getFees(@cessna174, @notSpecific)
		curFees.each do |curFee|
			if curFee.fee_type.fee_type_description == "landing"
				landing174 = curFee
			end
		end


		assert_equal(32, landing172.price)
		assert_equal(32, landing173.price)
		assert_equal(32, landing174.price)

		ramp172 = nil
		curFees = getFees(@cessna172, @notSpecific)
		curFees.each do |curFee|
			if curFee.fee_type.fee_type_description == "ramp"
				ramp172 = curFee
			end
		end

		assert_equal(19, ramp172.price)

		ramp173 = nil
		curFees = getFees(@cessna173, @notSpecific)
		curFees.each do |curFee|
			if curFee.fee_type.fee_type_description == "ramp"
				ramp173 = curFee
			end
		end

		assert_equal(39, ramp173.price)

		ramp174 = nil
		curFees = getFees(@cessna174, @notSpecific)
		curFees.each do |curFee|
			if curFee.fee_type.fee_type_description == "ramp"
				ramp174 = curFee
			end
		end

		assert_equal(39, ramp174.price)
	end

	test "fbo does not have a category" do # What if they only have heavy and light turboprops, for example?
		@missingCategory = fbos(:missing_category_fbo)
		@cessna425 = airplanes(:cessna425)
		@cessna426 = airplanes(:cessna426)
		@cessna427 = airplanes(:cessna427)

		landing425 = nil
		curFees = getFees(@cessna425, @missingCategory)
		curFees.each do |curFee|
			if curFee.fee_type.fee_type_description == "landing"
				landing425 = curFee
			end
		end
		assert_equal(true, landing425.is_estimate)
		assert_equal(18, landing425.price)

		landing426 = nil
		curFees = getFees(@cessna426, @missingCategory)
		curFees.each do |curFee|
			if curFee.fee_type.fee_type_description == "landing"
				landing426 = curFee
			end
		end

		assert_equal(true, landing425.is_estimate)
		assert_equal(16, landing426.price)

		landing427 = nil
		curFees = getFees(@cessna427, @missingCategory)
		curFees.each do |curFee|
			if curFee.fee_type.fee_type_description == "landing"
				landing427 = curFee
			end
		end
		
		assert_equal(true, landing425.is_estimate)
		assert_equal(18, landing427.price)
	end

=begin
	test "ensure fees still work with extra information" do
		@jetAir = fbos(:jet_air)
		@cessna1000 = airplanes(:cessna1000)

		targetFee = nil

		curFees = getFees(@cessna1000, @jetAir, "day", 0, "12:00".to_time)
		curFees.each do |curFee|
			if curFee.fee_type.fee_type_description == "landing"
				targetFee = curFee
			end
		end

		assert_equal(fees(:jet_air_jet_landing_extra_info).price, targetFee.price)
	end
=end

end
