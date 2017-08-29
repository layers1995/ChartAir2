require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'fileutils'


def parse(state, city, airportName, url)
  sleep(0.8)

  # TODO This program does not do the following: 
  # Get information from private airports
  # Get information from military airports

  page = Nokogiri::HTML(open(url))
  #if page.text.include?("Privately-owned") # "Open to the public"
  if page.text.include?("Private use.")
    # do nothing
  else
    airportCode = url[url.index("airport/") + 8 .. -1] # find the index of "airport/", add 8 to it to get to the call number, then go to the end of the string.
    # I feel gross doing this. there is definitely a better way, but I don't know what it is.
    
    latitude = "" # variables that need to declared outside the for each loop or else ruby gets mad at me.
    longitude = ""
    ownerPhone = ""
    managerPhone = ""

    data = page.css("table").css("tr").css("td")
    data.each do |var|
      if var.text.include?("Lat/Long:") && var.text.length == 10 # get latitude and longitude
      # For whatever reason, the entire html document gets thrown into the for each loop. The length check is to ensure that is ignored.  
      # Nothing like a good hack to make your code work. I'm sorry future me/anyone else who sees this
        
        latLong = data[data.index(var) + 1].text
        # var just tells me where the latitude and longitude are. 
        # To actually get them, I have to look in the next td, so the index needs to be increased by 1

        #latitude = latLong.match(/[0-9]*\-[0-9]*\-[0-9]*.[0-9]*[SN]/)[0] # This gets another format for latitude and longitude. Decimal format is apparently easier though
        #longitude = latLong.match(/[0-9]*\-[0-9]*\-[0-9]*.[0-9]*[WE]/)[0]
        latLong = latLong.scan(/(\-?[0-9]{2,3}.[0-9]{7})+/) # Get decimal format for latitude and longitude
        # scan matches all regexes and puts them into an array
        latitude = latLong[0][0]
        longitude = latLong[1][0]
      elsif (var.text.include?("Ownership:"))
        ownerPhone = data[data.index(var) + 3].text.match(/\(?[0-9]{3}\)?[ \-][0-9]{3}[ \-][0-9]{4}/)
        if ownerPhone.class != NilClass
          ownerPhone = data[data.index(var) + 3].text.match(/\(?[0-9]{3}\)?[ \-][0-9]{3}[ \-][0-9]{4}/)[0]
          ownerPhone = ownerPhone.gsub(/\(|\)/, "") # sometimes phone numbers are in (123) 456-7890 format. Sometimes they're in 123 456 7890 format too. Fuck airnav
          ownerPhone = ownerPhone.gsub(/ /, "-")    # we want 123-456-7890 to be consistent
        else
          ownerPhone = ""
        end

        managerPhone = data[data.index(var) + 5].text.match(/\(?[0-9]{3}\)?[ \-][0-9]{3}[ \-][0-9]{4}/)
        if managerPhone.class != NilClass
          managerPhone = data[data.index(var) + 5].text.match(/\(?[0-9]{3}\)?[ \-][0-9]{3}[ \-][0-9]{4}/)[0]
          managerPhone = managerPhone.gsub(/\(|\)/, "")
          managerPhone = managerPhone.gsub(/ /, "-")
        else
          managerPhone = ""
        end
      end
=begin
      elsif (var.text.include?("Publicly-owned") and var.text.length == 14) or (var.text.include?("Privately-owned") and var.text.length == 15)# Get phone numbers
        # var just tells me where the numbers are. 
        # To actually get them, I have to look through the next couple tds for phone numbers
        ownerPhone = data[data.index(var) + 2].text.match(/\(?[0-9]{3}\)?[ \-][0-9]{3}[ \-][0-9]{4}/)
        if ownerPhone.class != NilClass
          ownerPhone = data[data.index(var) + 2].text.match(/\(?[0-9]{3}\)?[ \-][0-9]{3}[ \-][0-9]{4}/)[0]
          ownerPhone = ownerPhone.gsub(/\(|\)/, "") # sometimes phone numbers are in (123) 456-7890 format. Sometimes they're in 123 456 7890 format too. Fuck airnav
          ownerPhone = ownerPhone.gsub(/ /, "-")    # we want 123-456-7890 to be consistent
        else
          ownerPhone = ""
        end
        

        managerPhone = data[data.index(var) + 4].text.match(/\(?[0-9]{3}\)?[ \-][0-9]{3}[ \-][0-9]{4}/)
        if managerPhone.class != NilClass
          managerPhone = data[data.index(var) + 4].text.match(/\(?[0-9]{3}\)?[ \-][0-9]{3}[ \-][0-9]{4}/)[0]
          managerPhone = managerPhone.gsub(/\(|\)/, "")
          managerPhone = managerPhone.gsub(/ /, "-")
        else
          managerPhone = ""
        end
      end
=end
    end
    if ownerPhone.length > 0 || managerPhone.length > 0
      puts state + " " + airportName + " " + ownerPhone + " " + managerPhone
      $airportSeedData.printf("%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n", airportCode.strip(), airportName.strip(), ownerPhone.strip(), managerPhone.strip(), latitude.strip(), longitude.strip(), state.strip(), city.strip())
    else
      puts "not there" + airportName
    end
  end
end

=begin
def crawl(url)
  state = url[url.rindex('/')+1..-1].strip()
  page = Nokogiri::HTML(open(url))

  rows = page.css("table[cellspacing='2'] tr")
  rows[1..-1].each do |tr|
    cols = tr.css('td')
    link = cols[0].css('a')[0]["href"]

    if link[1] == 'a'
      link = 'http://www.airnav.com' + link
    end

    city = cols[2].text.strip()
    airport = cols[4].text.strip()
    parse(state, city, airport, link)
  end
end
=end

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
      parse(state, city, airport, link)
    end
  end
end

def eachState(url, startIndex)
  linkArray = Array.new
  page = Nokogiri::HTML(open(url))
  page.css("td").css("a").each do |curData|
    if curData["href"].include?("/airports/us/") and linkArray.include?(curData["href"]) == false
      linkArray << curData["href"]
    end
  end
  for curStateIndex in startIndex..linkArray.length
    link = "http://airnav.com" + linkArray[curStateIndex]
    puts link
    crawl(link)
  end
end


if __FILE__ == $0
  $airportSeedData = File.open("full_airport_data", "a") 
# global variable for the file to save airport data to.
# This way I don't have to pass the file from one method to another
# I could rewrite it so functions are called from main, and return values for one function are passed to another


  #parse('IL', 'Chicago', 'Midway', 'http://www.airnav.com/airport/44IN')

  #crawl('http://airnav.com/airports/us/IL')
  #crawl('http://airnav.com/airports/us/IN')
  #crawl('http://airnav.com/airports/us/MI')
  #crawl('http://airnav.com/airports/us/MN')
  #crawl('http://airnav.com/airports/us/OH')

  #crawl('http://airnav.com/airports/us/TX', "Lackey Aviation Airport")

  eachState("http://airnav.com/airports/us", 44)
  $airportSeedData.close()
end