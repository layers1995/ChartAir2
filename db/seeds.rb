# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
Airplane.delete_all
City.delete_all
Airport.delete_all
Fbo.delete_all
Classification.delete_all
Category.delete_all
FeeType.delete_all
Fee.delete_all

# Grab FBOs by a combination of their name and phone number to ensure that it's unique
def getFboId(fboName, fboPhone)
	return Fbo.find_by( :name => fboName, :phone => fboPhone).id
end



Airplane.create({ :manufacturer => "cessna", :model => "172 skyhawk", :engine_class => "single engine piston", :weight => 2300, :height => 107, :wingspan => 433, :length => 326})

City.create({ :name => "galesburg", :state => "il", :latitude => "40", :longitude => "40" })

Airport.create({ :city_id => City.find_by( :name => "galesburg", :state => "il" ).id,
								 :airport_code => "gbg", :name => "galesburg municipal airport", 
								 :latitude => "40.5", :longitude => "40.5" })
 
Fbo.create({ :airport_id => Airport.find_by( :airport_code => "gbg").id, 
						 :name => "Jet Air", :phone => "309-342-3134", :alternate_phone => "" })

classificationTypes = File.open(Rails.root.join("db", "seed_data", "classification_types"))
classificationTypes.each do |curClassificationType|
	Classification.create({ :classification_description => curClassificationType.strip })
end

Category.create({ :classification_id => Classification.find_by( :classification_description => "no fee").id,
									:category_description => "no fee"})

Category.create({ :classification_id => Classification.find_by( :classification_description => "flat rate").id,
									:category_description => "flat rate"})

Category.create({ :classification_id => Classification.find_by( :classification_description => "engine type").id,
									:category_description => "single engine piston"})

Category.create({ :classification_id => Classification.find_by( :classification_description => "engine type").id,
									:category_description => "twin engine piston"})

feeTypes = File.open(Rails.root.join("db", "seed_data", "fee_types"))
feeTypes.each do |curFeeType|
	FeeType.create({ :fee_type_description => curFeeType.strip })
end

Fee.create({ :price => 10, :fee_type_id => FeeType.find_by( :fee_type_description => "landing").id, :fbo_id => getFboId("Jet Air", "309-342-3134"), 
						 :category_id => Category.find_by( :category_description => "single engine piston").id })









