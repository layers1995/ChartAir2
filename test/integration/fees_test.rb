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

		# check that I can grab the classification from the category
		engineType = Classification.find(jetAir.classification_id)
		assert_equal(classifications(:engine_type).classification_description, engineType.classification_description)
	end

	test "multiple fee types retrievable" do
		@jetAir = fbos(:jet_air)
		curFees = getFees(@cessna172, @jetAir)
		targetFees = Fee.joins(:fbo).joins(:category).where('categories.category_description == "piston single" and fbos.name == "Jet Air, inc."')
		curFees.each do |curFee|
			assert_includes(targetFees, curFee)
		end
	end

	test "engine type fees retrievable" do
		@jetAir = fbos(:jet_air)

		curFees = getFees(@cessna172, @jetAir)
		curFee = getFeeType(curFees, "landing")
		#curFee = curFees.find_by( :fee_type => FeeType.find_by(:fee_type_description => "landing"))
		assert_equal(fees(:jet_air_sep_landing).price, curFee.price)

		curFees = getFees(@cessna425, @jetAir)
		curFee = getFeeType(curFees, "landing")
		#curFee = curFees.find_by( :fee_type => FeeType.find_by(:fee_type_description => "landing" ))
		assert_equal(fees(:jet_air_tet_landing).price, curFee.price)
	end

	test "model fees retrievable" do
		@jetFlair = fbos(:jet_flair)

		curFees = getFees(@cessna172, @jetFlair)
		curFee = curFees.find_by( :fee_type => FeeType.find_by(:fee_type_description => "landing"))
		assert_equal(fees(:jet_flair_172_landing).price, curFee.price)

		curFees = getFees(@cessna425, @jetFlair)
		curFee = curFees.find_by( :fee_type => FeeType.find_by(:fee_type_description => "landing"))
		assert_equal(fees(:jet_flair_425_landing).price, curFee.price)
	end

	test "no fees retrievable" do
		@noFeeFbo = fbos(:no_fee_fbo)

		curFees = getFees(@cessna172, @noFeeFbo)
		curFee = curFees.find_by( :fee_type => FeeType.find_by(:fee_type_description => "landing"))
		assert_equal(0, curFee.price)

		curFees = getFees(@cessna425, @noFeeFbo)
		curFee = curFees.find_by( :fee_type => FeeType.find_by(:fee_type_description => "landing"))
		assert_equal(0, curFee.price)
	end

	test "flat rate fees retrievable" do
		@flatRateFbo = fbos(:flat_rate_fbo)

		curFees = getFees(@cessna172, @flatRateFbo)
		curFee = curFees.find_by( :fee_type => FeeType.find_by(:fee_type_description => "landing"))
		assert_equal(fees(:flat_rate_fbo_landing).price, curFee.price)

		curFees = getFees(@cessna425, @flatRateFbo)
		curFee = curFees.find_by( :fee_type => FeeType.find_by(:fee_type_description => "landing"))
		assert_equal(fees(:flat_rate_fbo_landing).price, curFee.price)
	end

=begin
	test "weight range fees retrievable" do
		@weightRangeFbo = fbos(:weight_range_fbo)

		curFees = getFees(@cessna172, @weightRangeFbo)
		curFee = curFees.find_by( :fee_type => FeeType.find_by(:fee_type_description => "landing"))
		assert_equal(fees(:weight_range_fbo_small_landing).price, curFee.price)

		curFees = getFees(@cessna425, @weightRangeFbo)
		curFee = curFees.find_by( :fee_type => FeeType.find_by(:fee_type_description => "landing"))
		assert_equal(fees(:weight_range_fbo_medium_landing).price, curFee.price)
	end
=end
		
	test "weight fees retrievable" do
		@weightFbo = fbos(:weight_fbo)

		curFees = getFees(@cessna172, @weightFbo)
		#curFees = applyMultiplier(@cessna172, curFees)

		curFees.each do |curFee|
			if curFee.fee_type.fee_type_description == "landing"
				assert_equal(22, curFee.price)
			end
		end

		curFees = getFees(@cessna425, @weightFbo)
		curFees = applyMultiplier(@cessna425, curFees)

		curFees.each do |curFee|
			if curFee.fee_type.fee_type_description == "landing"
				assert_equal(88, curFee.price)
			end
		end
	end
end
