class PlanTripController < ApplicationController
  
  def trip_details
      
    if not logged_in?
      redirect_to login_path and return
    end
    
    @id=params[:airplane_id]
    
    gon.cities= City.all
    gon.curAirplanes=current_airplanes
    gon.selectedPlane=@tailnumber
    
    if current_airplanes.length==0
      flash[:notice] = "Add an airplane before planning a trip"
        redirect_to profile_path and return
    end
    
    @plan_trip=PlanTrip.new
    
  end

  def results
   
    #make datetime
    tempArr=[params[:plan_trip]["arrival_time(1i)"], params[:plan_trip]["arrival_time(2i)"], params[:plan_trip]["arrival_time(3i)"], params[:plan_trip]["arrival_time(4i)"], params[:plan_trip]["arrival_time(5i)"]]
    arrival_time= formatTime(tempArr)
    tempDepart=[params[:plan_trip]["depart_time(1i)"], params[:plan_trip]["depart_time(2i)"], params[:plan_trip]["depart_time(3i)"], params[:plan_trip]["depart_time(4i)"], params[:plan_trip]["depart_time(5i)"]]
    depart_time=formatTime(tempDepart)
    
    if arrival_time==nil || depart_time==nil
      @plan_trip=PlanTrip.new
      @tailnumber= params[:plan_trip][:tailnumber]
      gon.cities= City.all
      gon.curAirplanes=current_airplanes
      gon.selectedPlane=@tailnumber
      render 'trip_details' and return
    end
    
    flashErrors(params[:plan_trip], arrival_time, depart_time)
    
    #send data to the database
    newData=PlanTrip.new(:arrival_time =>  arrival_time, :depart_time => depart_time, :user_id => current_user.id, :state => params[:plan_trip][:state], :city => params[:plan_trip][:city], :distance => params[:plan_trip][:distance], :nights => params[:plan_trip][:nights], :tailnumber => params[:plan_trip][:tailnumber])
    
    if newData.save
  	  flash[:notice] = ""
    	@tailnumber=params[:plan_trip][:tailnumber]
    	@nights=params[:plan_trip][:nights]
    	
    	#get all of the needed time infomation for function
      timeInfo= get_time_length_time_unit(arrival_time, depart_time)
    
    	#get the current city
    	curCity= City.find_by(:name => params[:plan_trip][:city], :state => params[:plan_trip][:state])
    	#get a refrence to the airplane being used
    	curAirplane= Airplane.find_by(:id => AirplaneUser.find_by(:tailnumber => @tailnumber).airplane_id)
    	
    	#Find all the airports within the area
    	airports=Airport.all
    	airportList=Array.new
    	
    	airports.each do |airport|
  
    	if airport.withinRadius(curCity.latitude, curCity.longitude, params[:plan_trip][:distance].to_f)<params[:plan_trip][:distance].to_f
    	    airportList.push(airport.id)
    	end
  
    	end
    	#find all the Fbos at these airports
    	@Fbos= Fbo.where(:airport_id => airportList)
    	
    	#create dictionary to send to js
    	feeDict= {}
    	
    	#get all the fees assocated with those fbos
    	@Fbos.each do |fbo|
    	    
    	  #make a dictorany given the FBO name  
    	  feeDict[fbo.name]= {}
    	  feeTotal=0;
    	  
    	  #get all the fees at a given airport
        if !fbo.classification_id.nil?
          print timeInfo[1].to_s 
      	  feeRecord=getFees(curAirplane, fbo, timeInfo[0], timeInfo[1], arrival_time)
        end
    	  
        if feeRecord!=nil
          feeRecord.each do |fee|
            #name of the fee and the price
            feeTotal+=fee.price
            feeDict[fbo.name][FeeType.find_by(:id => fee.fee_type_id).fee_type_description]=fee.price
          end
        end
    	  
    	  #add all other relivant information to dictonary like distance and airport
    	  fboAirport=Airport.find_by(:id => fbo.airport_id)
    	  feeDict[fbo.name]["total"]= feeTotal
    	  feeDict[fbo.name]["airport"]= fboAirport.name
    	  feeDict[fbo.name]["distance"]= fboAirport.withinRadius(curCity.latitude,curCity.longitude,params[:plan_trip][:distance].to_f).to_i.to_s + " (mi)";
    	  feeDict[fbo.name]["latitude"]=fboAirport.latitude;
    	  feeDict[fbo.name]["longitude"]=fboAirport.longitude;
    	  
    	end
    	
    	#send values to js
    	gon.destination=curCity.latitude.to_s+","+curCity.longitude.to_s
    	gon.dict= feeDict
    	gon.tailnumber=@tailnumber
    	gon.time= arrival_time
    	gon.time2= depart_time
    else
      
      @plan_trip=PlanTrip.new
      @tailnumber= params[:plan_trip][:tailnumber]
      gon.cities= City.all
      gon.curAirplanes=current_airplanes
      gon.selectedPlane=@tailnumber
      render 'trip_details'
    end
    
  end
  
  private 
  
  def get_time_length_time_unit(arrival, depart)
    
    timeInfo= []
    
    hoursAppart=((depart-arrival)*24)
    
    if(hoursAppart>=24)
      timeInfo[0]="day"
      timeInfo[1]=(hoursAppart/24).to_i
    else
      timeInfo[0]="hour"
      timeInfo[1]=(hoursAppart)
    end
    
    return timeInfo
    
  end
  
  def formatTime(timeArray)
    val=timeArray[1]+"/"+timeArray[2]+"/"+timeArray[0]+" "
    
    if(timeArray[3].to_i>12)
      timeArray[3]=timeArray[3].to_i-12;
      val=val+timeArray[3].to_s+":"+timeArray[4]+ " PM"
    else
      val=val+timeArray[3].to_s+":"+timeArray[4]+ " AM"
    end
    
    return DateTime.strptime(val, "%m/%d/%Y %H:%M %p") rescue nil
    
  end
  
  def getFees(airplane, fbo, timeUnit = nil, timeLength = 0, landingTime = nil)
		
  		if !landingTime.nil?
  			landingTime = timeToMinutes(landingTime)
  		end
  
  		multiplier = 1
  		classification = Classification.find(fbo.classification_id)
  		# get the category based on the classification and the airplane
  		case classification.classification_description
  		when "no fee"
  			category = Category.find_by( :category_description => "no fee" )
  		when "flat rate"
  			category = Category.find_by( :category_description => "flat rate" )
  		when "engine type"
  			category = Category.find_by( :category_description => airplane.engine_class )
  		when "make and model"
  			category = Category.find_by( :category_description => airplane.model )
  		when "weight range"
  			planeWeight = airplane.weight
  			# I really doubt this will actually work, but that's the idea
  			category = Category.find_by( "minimum < ? AND maximum > ?", planeWeight, planeWeight )
  		when "weight"
  			category = Category.find_by( :category_description => "weight" )
  			#multiplier = airplane.weight / curFee.unit_magnitude
  			# I think this is where I'm going to need to redesign the schema. Maybe just add a column to category saying how much per x the fee is charged. So if it's $5 every 1000 pounds, that new column would be 1000
  		else
  			puts "That wasn't supposed to happen"
  		end
  
  		# return all fees where the category and fbo match what we're looking for. Should be up to 6 fees based on the different fee types
  		if !category.nil? # make sure that the category actually exists before trying to return anything
  			fees = Fee.where( category: [category, Category.find_by( :category_description => "flat rate")], :fbo => fbo )
  
  			fees = fees.reject do |curFee|
        # Get rid of the fees that aren't supposed to be there for this search
  
  				if !curFee.start_time.nil? and !curFee.end_time.nil? # If the fee has a start time and an end time, make sure it falls in the right time period.
  
  					startTime = timeToMinutes(curFee.start_time)
  					endTime = timeToMinutes(curFee.end_time)
  					landingTime < startTime or landingTime > endTime
  
  				elsif !curFee.time_unit.nil? # reject fees that use the wrong time unit
  					curFee.time_unit != timeUnit
  				end
  			end
  
  			fees = applyMultiplier(airplane, fees, timeUnit, timeLength, landingTime)
  			return fees
  		else
  			return nil
		end
  end
  
  def timeToMinutes(time) # takes a time and turns it into the minute of that day so it's easier to compare.
		time = time.strftime("%R") # Change the time to a string of format "HH:MM"
		hour = (time[0] + time[1]).to_i
		minute = (time[3] + time[4]).to_i

		return hour * 60 + minute # minutes = 60*hours + minutes
	end
	
	def applyMultiplier(airplane, fees, timeUnit, timeLength, landingTime)
		feeArray = fees.to_a
		multiplier = 1
		fees.each do |curFee|
			case curFee.category.category_description
			when "weight", !curFee.unit_magnitude.nil?
				multiplier = airplane.weight / curFee.unit_magnitude
			end

			if !curFee.unit_price.nil?
				curFee.price += curFee.unit_price * multiplier
			end

			if !curFee.time_unit.nil? and !curFee.time_price.nil? and curFee.free_time_length.nil?
				curFee.price += timeLength * curFee.time_price
			end

			if !curFee.free_time_unit.nil? and !curFee.free_time_length.nil? and !curFee.time_unit.nil? and !curFee.time_price.nil? and !timeLength.nil?
				curFee.price += (timeLength - curFee.free_time_length) * curFee.time_price
			end

		end
		return feeArray	
	end
 
  #takes an active record of airports and returns an array
  def getAirportIds(airports)
     
    ids= Array.new(airports.length)
     
    airports.each do |airport|
      ids[i]=airport.id
    end
     
    return ids
     
  end
  
  def flashErrors(plan_trip_params, arrival_time, depart_time)

      if arrival_time < Date.tomorrow
          flash[:n1]="You must plan your trip at least one day in advance"
      end

      if arrival_time > depart_time
          flash[:n2]=" You must arrive at the airport before you can depart"
      end
      
      if (plan_trip_params[:distance].to_i)<10
          flash[:n3]="Distance must be over 10 miles"
      end 
      
      if (plan_trip_params[:distance].to_i)>76
          flash[:n4]=["Distance can not be over 75 miles"]
      end 
  end
 
  def plan_trip_params
    params.require(:city).permit(:state, :distance, :airplane, :filter)
  end
  
end
