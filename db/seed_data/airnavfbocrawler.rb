require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'fileutils'


def parseFbos(state, city, airportName, url)
	# TODO change this so it uses hashmaps instead. Seems like it would be a little more intuitive.

  page = Nokogiri::HTML(open(url))

  fboData = Hash.new
  airportCode = url[url.index("airport/") + 8 .. -1] # find the index of "airport/", add 8 to it to get to the call number, then go to the end of the string.

  if page.text =~ /aircraft operations:( avg)? [0-9]+\/[a-z]+/i
    averageOperations = page.text.match(/aircraft operations:( avg)? [0-9]+\/[a-z]+/i)[0].strip.downcase
    timeSpan = averageOperations.match(/(day|week|month|year)/i)[0].strip.downcase
    averageOperations = averageOperations.match(/[0-9]+/)[0].strip.to_i
    if timeSpan == "day"
      averageOperations *= 30
    elsif timeSpan == "week"
      averageOperations *= 4
    elsif timeSpan == "month"
    elsif timeSpan == "year"
      averageOperations /= 12
    else
      averageOperations = 0
    end
  end

  page.css("table[border='0']").each do |curTable|
    # Only check the airports businesses section
    if curTable.text.include?("FBO, Fuel Providers, and Aircraft Ground Support")

      # Only check for fbos at the airport. The other stuff is useless information
      curTable.css("tr").each do |curRow|
        if curRow.text.include?("Things to do: Attractions on or near the airport") or
        curRow.text.include?("Alternatives at nearby airports") or
        curRow.text.include?("Aviation Businesses, Services, and Facilities") or
        curRow.text.include?("Getting Around: Taxi, Limo, Rental Cars, Mass Transit") or
        curRow.text.include?("Things to do: Attractions on or near the airport") or
        curRow.text.include?("Would you like to see your business listed on this page") or
        curRow.text.include?("Where to Stay: Hotels, Motels, Resorts, B&Bs, Campgrounds") or
        curRow.text.include?("Where to Eat: Catering, Restaurants, Food shops") or
        curRow.text.include?("Miscellaneous businesses, services, or facilities")
          break
        end

        fboName = ""
        fboNumber = ""
        # It seems like all the FBOs are in this format fortunately
        curRow.css("td[width='240']").each do |curFbo|
          #puts curFbo
          # sometimes the fbo name is text. the 100 is a number I picked at random just to ensure I don't get things bigger than what I want.
          if curFbo.text.strip.length < 100 and curFbo.text.strip.length > 0
            fboName = curFbo.text.strip
          else
            # and sometimes the fbo name is in an image alt
            # not entirely sure how this code works, but it gets the alt text of images.
            fboName = curFbo.css("img").map{ |i| i['alt'] }[0]
          end
        end

        # phone numbers always seem to have td nowrap align=left
        curRow.css("td[nowrap][align='left']").each do |curNumber|
          if curNumber.text.include?("on airport") == false
            # match phone numbers
            fboNumber = curNumber.text.match(/([0-9]{3}\-[0-9]{3}\-[0-9]{4})+/)
            # make sure there was a match, then get the phone number
            if fboNumber != nil
              fboNumber = fboNumber[0]

              if fboNumber.length == 24 # if there are two numbers, separate them by commas. This assumes there aren't more than 2
                fboNumber = fboNumber[0..11] + ", " + fboNumber[12..23]
              end
            end
          end
        end
        if fboName != nil and fboNumber != nil and fboName.length > 0 and fboNumber.length > 0
          # If the name and phone number both exist, add them to the list
          fboData[fboName] = fboNumber
        end
      end
    end
  end

  fboData.each do |curFbo|
    printf("%s\t%s\t%s\t%s\t%s\t%s\n", city, curFbo[0].strip, curFbo[1].strip, airportName.strip, state, averageOperations)
    #$fboSeedData.printf("%s\t%s\t%s\t%s\t%s\t%s\t%s\n", state, city, airportName, airportCode, curFbo[0].strip, curFbo[1].strip, averageOperations)
    $fboSeedData.printf("%s\t%s\t%s\t%s\t%s\t%s\n", state, city, airportName, airportCode, curFbo[0].strip, curFbo[1].strip)
  end

end


def crawl(url, startAirport = nil)

  # if the start airport is nil, begin at the top of the page
  beginParsing = startAirport.nil? ? true : false

  state = url[url.rindex('/')+1..-1]
  page = Nokogiri::HTML(open(url))

  rows = page.css("table[cellspacing='2'] tr")
  rows[1..-1].each do |tr|
    cols = tr.css('td')
    link = cols[0].css('a')[0]["href"]

    if link[1] == 'a'
      link = 'http://www.airnav.com' + link
    end

    city = cols[2].text
    airport = cols[4].text

    # if we've reached the airport that we wanted to start at, begin parsing data
    if airport == startAirport
      beginParsing = true
    end

    # if we're supposed to be parsing data, then do it.
    if beginParsing
      parseFbos(state, city, airport, link)
    end
  end
end

if __FILE__ == $0
  #parseFbos('IL', 'Chicago', 'Midway', 'http://www.airnav.com/airport/KCIU')
=begin
  $fboSeedData = File.open("fbo_call_data_prioritized/minnesota.txt", "a")
  crawl('http://airnav.com/airports/us/MN')
  $fboSeedData.close()
=end

  $fboSeedData = File.open("fbo_call_data/illinois.txt", "a")
  crawl('http://airnav.com/airports/us/IL')
  $fboSeedData.close()

  $fboSeedData = File.open("fbo_call_data/ohio.txt", "a")
  crawl('http://airnav.com/airports/us/OH')
  $fboSeedData.close()

  $fboSeedData = File.open("fbo_call_data/michigan.txt", "a")
  crawl('http://airnav.com/airports/us/MI')
  $fboSeedData.close()

  $fboSeedData = File.open("fbo_call_data/indiana.txt", "a")
  crawl('http://airnav.com/airports/us/IN')
  $fboSeedData.close()

  $fboSeedData = File.open("fbo_call_data/minnesota.txt", "a")
  crawl('http://airnav.com/airports/us/MN')
  $fboSeedData.close()

end
