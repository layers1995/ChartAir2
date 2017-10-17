if __FILE__ == $0
	$fboData = File.open("fbo_data_entrecorps/all.txt", "a")

	folderPath = Rails.root.join("db", "seed_data", "fbo_call_data")
	#folderPath = "db/seed_data/fbo_call_data"
	Dir.foreach(folderPath) do |curFile|
	  next if curFile == '.' or curFile == '..' # do work on real items
	  filePath = Rails.root.join("db", "seed_data", "fbo_call_data", curFile)
	  transferFile(filePath)
	end
=begin
	folderPath = Rails.root.join("db", "seed_data", "fbo_data_entrecorps")
		Dir.foreach(folderPath) do |curFile|
		  next if curFile == '.' or curFile == '..' # do work on real items
		  filePath = Rails.root.join("db", "seed_data", "fbo_data_entrecorps", curFile)
		  transferFile(filePath)
		end
	end
=end
	$fboData.close()
end

def transferFile(curFile)
	curText = open(curFile).read
	curText.each_line do |curFbo|
		state, city, airportName, airportCode, fboName, phoneNumbers = curFbo.split(",")
		$fboData.printf("%s\t%s\t%s\t%s\t%s\t%s\n", state, city, airportName, airportcode, fboName, phoneNumbers)
	end
end


# Ok, so for some reason Rails.root wasn't working in this file, so I just moved this code in a seeds.rb method and called it from there... yes it's dumb
=begin
	$fboData = File.open(Rails.root.join("db", "seed_data", "fbo_data_entrecorps", "all.txt"), "a")

	folderPath = Rails.root.join("db", "seed_data", "fbo_call_data")
	#folderPath = "db/seed_data/fbo_call_data"
	Dir.foreach(folderPath) do |curFile|
	  next if curFile == '.' or curFile == '..' # do work on real items
	  filePath = Rails.root.join("db", "seed_data", "fbo_call_data", curFile)
	  transferFile(filePath)
	end

	folderPath = Rails.root.join("db", "seed_data", "fbo_call_data(startup_term)")
	Dir.foreach(folderPath) do |curFile|
	  next if curFile == '.' or curFile == '..' # do work on real items
	  filePath = Rails.root.join("db", "seed_data", "fbo_call_data(startup_term)", curFile)
	  transferFile(filePath)
	end
	$fboData.close()
=end