require 'nokogiri'
require 'open-uri'
require 'fileutils'

def parseAirplane(url, manufacturer = nil, country = nil, planeModel = nil)

	airplaneSeedData = File.open("airplane_seed_data", "a") 

	page = Nokogiri::HTML(open(url)) # open the page

	airplaneData = Hash.new # create a hash to store the airplane information

	# Take the parentheses out of the country
	country = country.gsub(/[\(\)]/, "")

	airplaneData[:manufacturer] = manufacturer # add the manufacturer data to the hash
# declare variables to ruby doesn't get mad
	planeClass = nil
	numCrew = nil
	numPassengers = nil
	engineType = nil
	range = nil
	emptyWeight = nil
	maxWeight = nil
	wingspan = nil
	wingArea = nil
	length = nil
	height = nil

# It's easier to grab the model from the main page, so I don't need this anymore
=begin
# The only things found in the h3 information is the website url and the plane manufacturer/model. Take out the manufacturer and all you've got left is the model.
	page.css('h3').each do |curHeader|
		next if curHeader.text.downcase.include?("flugzeuginfo")
		planeModel = curHeader.text#.gsub(/#{manufacturer}/i, "")
		#puts planeModel.strip.downcase
	end
=end

	page.css('h4').each do |curHeader|
		planeClass = curHeader.text.strip.downcase
		#puts planeClass
	end

	data = page.css('table').css('td')

	data.each do |curData|

		if curData.text =~ /crew/i
			# If I find the table row that says "crew", then the next data is the number of crew
			numCrew = data[data.index(curData) + 1].text
			airplaneData[:num_crew] = numCrew
			#puts numCrew

		elsif curData.text =~ /passengers/i
			# If I find the table row that says "passengers", then the next data is the number of passengers
			numPassengers = data[data.index(curData) + 1].text
			airplaneData[:num_passengers] = numPassengers
			#puts numPassengers

		elsif curData.text =~ /propulsion/i
			# If I find the table row that says "propulsion", then the next data is the number of engines and the engine type
			engineType = data[data.index(curData) + 1].text
			airplaneData[:engine_type] = engineType
			#puts engineType

		elsif curData.text =~ /\Arange/i
			# If I find the table row that says "range", then adding 2 gives the range of the plane
			range = data[data.index(curData) + 2].text
			# just get the number of miles
			range = range.gsub(/[.]/, "")
			range = range.gsub(/\([0-9]+\)/, "")
			range = range.match(/[0-9 ]+mi/)[0]
			range = range.match(/[0-9]+/)[0]
			airplaneData[:range] = range
			#puts range

		elsif curData.text =~ /empty weight/i
			# If I find the table row that says "empty weight", then adding 2 gives the empty weight of the plane in pounds
			emptyWeight = data[data.index(curData) + 2].text
			emptyWeight = emptyWeight.gsub(/[.lbs ]/, "")
			emptyWeight = emptyWeight.gsub(/\([0-9]+\)/, "")

			airplaneData[:empty_weight] = emptyWeight
			#puts emptyWeight

		elsif curData.text =~ /max. takeoff weight/i
			# If I find the table row that says "max. takeoff weight", then adding 2 gives the max weight of the plane in pounds
			maxWeight = data[data.index(curData) + 2].text
			maxWeight = maxWeight.gsub(/[.lbs ]/, "")
			maxWeight = maxWeight.gsub(/\([0-9]+\)/, "")
			airplaneData[:max_weight] = maxWeight
			#puts maxWeight

		elsif curData.text =~ /wing span/i
			# If I find the table row that says "wing span", then adding 2 gives the wingspan of the plane in ft
			wingspan = data[data.index(curData) + 2].text
			wingspan = convertToInches(wingspan)

			airplaneData[:wing_span] = wingspan
			#puts wingspan

		elsif curData.text =~ /wing area/i
			# If I find the table row that says "wing area", then adding 2 gives the area of the wing in ft^2
			wingArea = data[data.index(curData) + 2].text

			# get rid of the square foot unit and just leave the number
			wingArea = wingArea.match(/[0-9]+/)[0].to_i
			airplaneData[:wing_area] = wingArea
			#puts wingArea

		elsif curData.text =~ /length/i
			# If I find the table row that says "length", then adding 2 gives the length of the plane in ft and in
			length = data[data.index(curData) + 2].text
			length = convertToInches(length)

			airplaneData[:length] = length
			#puts length

		elsif curData.text =~ /height/i
			# If I find the table row that says "height", then adding 2 gives the height of the plane in ft and in
			height = data[data.index(curData) + 2].text

			height = convertToInches(height)

			airplaneData[:height] = height
			#puts height

		end

	end

	airplaneSeedData.printf("%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n", manufacturer, country, planeModel, planeClass, numCrew, numPassengers, engineType, range, emptyWeight, maxWeight, wingspan, wingArea, length, height)
	printf("%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n", manufacturer, country, planeModel, planeClass, numCrew, numPassengers, engineType, range, emptyWeight, maxWeight, wingspan, wingArea, length, height)
end

def convertToInches(distance) # convert from format x ft y in to just inches
	# find the feet
	distanceFeet = distance.match(/[0-9]+ ft/)[0]
	# convert to number
	distanceFeet = distanceFeet.match(/[0-9]+/)[0].to_i
	# find the inches
	distanceInches = distance.match(/[0-9]+ in/)[0]
	# convert to number
	distanceInches = distanceInches.match(/[0-9]+/)[0].to_i

	# inches = ft * 12 + inches
	finalDistance = distanceFeet * 12 + distanceInches

	return finalDistance
end

def crawlSite(url)
	airplaneSeedData = File.open("airplane_seed_data", "a") 

	page = Nokogiri::HTML(open(url)) # open the page
	manufacturer = nil

	rows = page.css("table").css("td")
	for i in 0..rows.length - 1
		if rows[i].css("b").text.strip != ""
			manufacturer = rows[i].css("b").text.strip
			#puts manufacturer
		end
		if rows[i].css("small").text =~ /\([a-zA-Z ]+\)/
			country = rows[i].css("small").text
		end
		#if rows[i].css("b").text.strip == "" #and rows[i+1].css("b").text.strip != manufacturer
		rows[i].css("a").each do |curUrl|
			link = "http://www.flugzeuginfo.net" + curUrl["href"]
			planeModel = curUrl.text
			if !link.nil? and !manufacturer.nil? and !country.nil? and !planeModel.nil?
				catch404(link, manufacturer, country, planeModel)
			end
		end
	end
end

def catch404(url, manufacturer = nil, country = nil, planeModel = nil)
	page = Nokogiri::HTML(open(url)) do
		parseAirplane(url, manufacturer, country, planeModel)
	end
	rescue OpenURI::HTTPError => e
  if e.message == '404 Not Found'
    return
  end
end

if __FILE__ == $0
	url = "http:_www.flugzeuginfo.net_acdata_en.php.html"
	crawlSite(url)
	#catch404("http://www.flugzeuginfo.net/acdata_php/acdata_dornier_do28_en.php")
end
