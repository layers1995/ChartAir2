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

	test "get fee" do
		@jetAirLanding172 = fees(:jetAirOne)
		assert_equal(@jetAirLanding172.price, 10)
	end

end
