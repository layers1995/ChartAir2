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

	test "ensure foreign keys can grab information correctly" do
		# check that the fee is correct
		@jetAirLanding172 = fees(:jetAirOne)
		assert_equal(@jetAirLanding172.price, 10)

		# check that I can grab the fbo from the fee
		jetAir = Fbo.find(@jetAirLanding172.fbo_id)
		assert_equal(jetAir.name, "Jet Air, inc.")

		# check that I can grab the fee type from the fee
		landingFee = FeeType.find(@jetAirLanding172.fee_type_id)
		assert_equal(landingFee.fee_type_description, "landing")

		# check that I can grab the category from the fee
		singleEnginePiston = Category.find(@jetAirLanding172.category_id)	
		assert_equal(singleEnginePiston.category_description, "single engine piston")

		# check that I can grab the airport from the FBO
		galesburgAirport = Airport.find(jetAir.airport_id)
		assert_equal(galesburgAirport.name, "galesburg municipal airport")

		# check that I can grab the city from the airport
		galesburg = City.find(galesburgAirport.city_id)
		assert_equal(galesburg.name, "galesburg")

		# check that I can grab the classification from the category
		engineType = Classification.find(singleEnginePiston.classification_id)
		assert_equal(engineType.classification_description, "engine type")
	end
end
