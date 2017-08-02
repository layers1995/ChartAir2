require 'test_helper'

class FeesTest < ActionDispatch::IntegrationTest

=begin
	def setup
		@chicago = cities(:chicago)
		@galesburg = cities(:galesburg)
		@airportGalesburg = airports(:galesburgAirport)
		@airportOHare = airports(:ohare)
		@cessna172 = airplanes(:cessna172)
		@cessna452 = airplanes(:cessna452)
		@jetAir = fbos(:jetAir)
		@signature = fbos(:signature)
		@classEngine = classifications(:engineType)
		@feeTypeLanding = fee_types(:landing)
		@jetAirLanding172 = fees(:jetAirOne)
		@signaturelanding172 = fees(:signatureOne)
	end
=end

	test "ensure correct foreign key relations" do
		# check that the fee is correct
		@jetAirLanding172 = fees(:jet_air_one)

		# check that I can grab the fbo from the fee
		jetAir = Fbo.find(@jetAirLanding172.fbo_id)
		assert_equal(fbos(:jet_air).name, jetAir.name)

		# check that I can grab the fee type from the fee
		landingFee = FeeType.find(@jetAirLanding172.fee_type_id)
		assert_equal(fee_types(:landing).fee_type_description, landingFee.fee_type_description)

		# check that I can grab the category from the fee
		singleEnginePiston = Category.find(@jetAirLanding172.category_id)	
		assert_equal(categories(:single_engine_piston).category_description, singleEnginePiston.category_description)

		# check that I can grab the airport from the FBO
		galesburgAirport = Airport.find(jetAir.airport_id)
		assert_equal(airports(:galesburg_airport).name, galesburgAirport.name)

		# check that I can grab the city from the airport
		galesburg = City.find(galesburgAirport.city_id)
		assert_equal(cities(:galesburg).name, galesburg.name)

		# check that I can grab the classification from the category
		engineType = Classification.find(singleEnginePiston.classification_id)
		assert_equal(classifications(:engine_type).classification_description, engineType.classification_description)
	end

	test "multiple fee types retrievable" do
		@cessna172 = airplanes(:cessna172)
		@jetAir = fbos(:jet_air)
		curFees = getFees(@cessna172, @jetAir)
		targetFees = Fee.where( :category_id => Category.find_by( :category_description => "single engine piston").id,
														:fbo_id => Fbo.find_by( :) )
		assert_equals()
	end

	test "engine type fees retrievable" do
		@cessna172 = airplanes(:cessna172)
		@jetAir = fbos(:jet_air)
		curFees = getFees(@cessna172, @jetAir)
		curFee = curFees.find_by( :fee_type_id => FeeType.find_by(:fee_type_description => "landing").id)
		assert_equal(fees(:jet_air_one).price, curFee.price)

		@cessna425 = airplanes(:cessna425)
		@signature = fbos(:signature)
		curFees = getFees(@cessna425, @signature)
		curFee = curFees.find_by( :fee_type_id => FeeType.find_by(:fee_type_description => "landing").id)
		assert_equal(fees(:jet_air_one).price, curFee.price)
	end

end
