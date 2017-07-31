require 'test_helper'

class FeesTest < ActionDispatch::IntegrationTest

	def setup
=begin
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
=end
		@jetAirlanding172 = fees(:jetAirOne)
		#@signaturelanding172 = fees(:signatureOne)
	end

	test "get fee" do
		assert_equal(@jetAirlanding172.price, 10)
	end

end
