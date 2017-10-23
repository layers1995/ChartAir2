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
    
    #check to make sure times are not nil
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
    	curAirplane= Airplane.find_by(:id => AirplaneUser.find_by(:tailnumber => @tailnumber, :user_id => current_user.id).airplane_id)
    	
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
    	  feeTotal=0
    	  estimated=false
    	  
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
            
            if fee.is_estimate
              estimated=true
            end
            
          end
        end
    	  
    	  #add all other relivant information to dictonary like distance and airport
    	  fboAirport=Airport.find_by(:id => fbo.airport_id)
    	  feeDict[fbo.name]["total"]= feeTotal
    	  feeDict[fbo.name]["airport"]= fboAirport.name
    	  feeDict[fbo.name]["distance"]= fboAirport.withinRadius(curCity.latitude,curCity.longitude,params[:plan_trip][:distance].to_f).to_i.to_s + " (mi)";
    	  feeDict[fbo.name]["latitude"]=fboAirport.latitude;
    	  feeDict[fbo.name]["longitude"]=fboAirport.longitude;
    	  feeDict[fbo.name]["estimated"]=estimated
    	  
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

    classificationDesc = fbo.classification.classification_description

    if !landingTime.nil?
      landingTime = timeToMinutes(landingTime)
    end


    fees = Fee.where( :fbo => fbo )

    isEstimate = false

# Figure out if categories are missing so that the data retrieval is more complete
# WWWWHHHEEEEEEEEE
    if classificationDesc == "engine type"
# doesn't have piston multi light
      if !hasCategory(fees, "piston multi light") and hasCategory(fees, "piston multi heavy") and airplane.engine_class == "piston multi light"
        airplane.engine_class = "piston multi heavy"
        isEstimate = true
# doesn't have piston multi heavy
      elsif !hasCategory(fees, "piston multi heavy") and hasCategory(fees, "piston multi light") and airplane.engine_class == "piston multi heavy"
        airplane.engine_class = "piston multi light"
        isEstimate = true
# doesn't have turboprop single heavy
      elsif !hasCategory(fees, "turboprop single heavy") and hasCategory(fees, "turboprop single light") and airplane.engine_class == "turboprop single heavy"
        airplane.engine_class = "turboprop single light"
        isEstimate = true
# doesn't have turboprop single light
      elsif !hasCategory(fees, "turboprop single light") and hasCategory(fees, "turboprop single heavy") and airplane.engine_class == "turboprop single light"
        airplane.engine_class = "turboprop single heavy"
        isEstimate = true
# doesn't have turboprop twin light
      elsif !hasCategory(fees, "turboprop twin light") and hasCategory(fees, "turboprop twin medium") and airplane.engine_class == "turboprop twin light"
        airplane.engine_class = "turboprop twin medium"
        isEstimate = true
      elsif !hasCategory(fees, "turboprop twin light") and hasCategory(fees, "turboprop twin heavy") and airplane.engine_class == "turboprop twin light"
        airplane.engine_class = "turboprop twin heavy"
        isEstimate = true
# doesn't have turboprop twin medium
      elsif !hasCategory(fees, "turboprop twin medium") and hasCategory(fees, "turboprop twin heavy") and airplane.engine_class == "turboprop twin medium"
        airplane.engine_class = "turboprop twin heavy"
        isEstimate = true
      elsif !hasCategory(fees, "turboprop twin medium") and hasCategory(fees, "turboprop twin light") and airplane.engine_class == "turboprop twin medium"
        airplane.engine_class = "turboprop twin light"
        isEstimate = true
# doesn't have turboprop twin heavy
      elsif !hasCategory(fees, "turboprop twin heavy") and hasCategory(fees, "turboprop twin medium") and airplane.engine_class == "turboprop twin heavy"
        airplane.engine_class = "turboprop twin medium"
        isEstimate = true
      elsif !hasCategory(fees, "turboprop twin heavy") and hasCategory(fees, "turboprop twin light") and airplane.engine_class == "turboprop twin heavy"
        airplane.engine_class = "turboprop twin light"
        isEstimate = true
# doesn't have light jet
      elsif !hasCategory(fees, "light jet") and hasCategory(fees, "midsize jet") and airplane.engine_class == "light jet"
        airplane.engine_class = "midsize jet"
        isEstimate = true
      elsif !hasCategory(fees, "light jet") and hasCategory(fees, "super midsize jet") and airplane.engine_class == "light jet"
        airplane.engine_class = "super midsize jet"
        isEstimate = true
      elsif !hasCategory(fees, "light jet") and hasCategory(fees, "heavy jet") and airplane.engine_class == "light jet"
        airplane.engine_class = "heavy jet"
        isEstimate = true
# doesn't have midsize jet
      elsif !hasCategory(fees, "midsize jet") and hasCategory(fees, "super midsize jet") and airplane.engine_class == "midsize jet"
        airplane.engine_class = "super midsize jet"
        isEstimate = true
      elsif !hasCategory(fees, "midsize jet") and hasCategory(fees, "light jet") and airplane.engine_class == "midsize jet"
        airplane.engine_class = "light jet"
        isEstimate = true
      elsif !hasCategory(fees, "midsize jet") and hasCategory(fees, "heavy jet") and airplane.engine_class == "midsize jet"
        airplane.engine_class = "heavy jet"
        isEstimate = true
# doesn't have super midsize jet
      elsif !hasCategory(fees, "super midsize jet") and hasCategory(fees, "heavy jet") and airplane.engine_class == "super midsize jet"
        airplane.engine_class = "heavy jet"
        isEstimate = true
      elsif !hasCategory(fees, "super midsize jet") and hasCategory(fees, "midsize jet") and airplane.engine_class == "super midsize jet"
        airplane.engine_class = "midsize jet"
        isEstimate = true
      elsif !hasCategory(fees, "super midsize jet") and hasCategory(fees, "light jet") and airplane.engine_class == "super midsize jet"
        airplane.engine_class = "light jet"
        isEstimate = true
# doesn't have heavy jet
      elsif !hasCategory(fees, "heavy jet") and hasCategory(fees, "super midsize jet") and airplane.engine_class == "heavy jet"
        airplane.engine_class = "super midsize jet"
        isEstimate = true
      elsif !hasCategory(fees, "heavy jet") and hasCategory(fees, "midsize jet") and airplane.engine_class == "heavy jet"
        airplane.engine_class = "midsize jet"
        isEstimate = true
      elsif !hasCategory(fees, "heavy jet") and hasCategory(fees, "light jet") and airplane.engine_class == "heavy jet"
        airplane.engine_class = "light jet"
        isEstimate = true
      end
    end


    # For fees with the wrong engine type
    fees = fees.reject do |curFee|  
      if isEstimate
        curFee.is_estimate = true
      end
      curCategory = curFee.category.category_description

      if classificationDesc == "engine type" and curCategory != "flat rate" and curCategory != "no fee" and curCategory != "weight" and curCategory != "weight range"
        if curCategory == "jet"
          !airplane.engine_class =~ /jet/

        elsif curCategory == "turboprop"
          !airplane.engine_class =~ /turboprop/
        elsif curCategory == "turboprop single"
          !airplane.engine_class =~ /turboprop single/
        elsif curCategory == "turboprop multi"
          !airplane.engine_class =~ /turboprop multi/

        elsif curCategory == "piston"
          !airplane.engine_class =~ /piston/
        elsif curCategory == "piston multi"
          !airplane.engine_class =~ /piston multi/

        else
          curCategory != airplane.engine_class
        end
      end
    end

    # For fees that have a start time and end time that are in the wrong range
    fees = fees.reject do |curFee|
      curCategory = curFee.category.category_description

      if !curFee.start_time.nil? and !curFee.end_time.nil? # If the fee has a start time and an end time, make sure it falls in the right time period.
        
        startTime = curFee.start_time
        endTime = curFee.end_time
        # If the fee skips over midnight, add 1440 minutes (1 day) to the end time so the comparison works properly
        if startTime > endTime
          endTime += 1440
        end

        landingTime < startTime or landingTime > endTime
      end
    end

    # For fees that use the wrong time unit
    fees = fees.reject do |curFee|
      if !curFee.time_unit.nil? # reject fees that use the wrong time unit
        curFee.time_unit != timeUnit
      end
    end

    # For fees that are the wrong make/model
    fees = fees.reject do |curFee|
      curCategory = curFee.category.category_description

      if classificationDesc == "make and model" and curCategory != "flat rate" and curCategory != "no fee" and curCategory != "weight" and curCategory != "weight range"
        curCategory != airplane.model
      end
    end

    # For fees where the airplane weight doesn't fall in the weight range
    fees = fees.reject do |curFee|
      curCategory = curFee.category.category_description

      if curCategory == "weight range" and !curFee.unit_minimum.nil? and !curFee.unit_maximum.nil?
        airplane.weight < curFee.unit_minimum or airplane.weight > curFee.unit_maximum # reject fees if the airplane weight is less than the minimum or greater than the maximum
      end
    end

    fees = applyConditionalFees(airplane, fees, timeUnit, timeLength, landingTime)
    if fees.nil? or fees.length == 0
      #puts "check"
      return nil
    else
      return fees
    end
  end

  def getFeeType(fees, feeType)
    fees.each do |curFee|
      if curFee.fee_type_description == feeType
        return curFee
      end
    end
  end

  def hasCategory(fees, category)
    fees.each do |curFee|
      if curFee.category.category_description == category
        return true
      end
    end
    return false
  end

  def applyConditionalFees(airplane, fees, timeUnit, timeLength, landingTime)
    feeArray = fees.to_a
    multiplier = 1
    fees.each do |curFee|

      tempTimeLength = timeLength

      case curFee.category.category_description
      when "weight", !curFee.unit_magnitude.nil?, !fees.nil?
        multiplier = airplane.weight / curFee.unit_magnitude
      end

      if !curFee.unit_price.nil?
        curFee.price += curFee.unit_price * multiplier
      end

      # Check the case where the fbo gives free time before charging
      if !curFee.free_time_unit.nil? and !curFee.free_time_length.nil? and !curFee.time_unit.nil? and !curFee.time_price.nil? and !timeLength.nil?
        finalTime = timeLength - curFee.free_time_length
        if finalTime < 0
          finalTime = 0
        end
        curFee.price += finalTime * curFee.time_price

      # If they don't do free stuff
      elsif !curFee.time_unit.nil? and !curFee.time_price.nil? and curFee.free_time_length.nil?

        if curFee.price != 0 # If a fee is something like $50 + $30/night, it's $50 the first night, not $80
          if tempTimeLength >= 1 # wouldn't want negative times
            tempTimeLength -= 1
          end
          curFee.price += tempTimeLength * curFee.time_price

        else # However, if it's just $30/night, then staying for 1 night would be $30
          curFee.price += tempTimeLength * curFee.time_price
        end
      end   

    end
    return feeArray 
  end

  def timeToMinutes(time) # takes a time and turns it into the minute of that day so it's easier to compare.
    time = time.strftime("%R") # Change the time to a string of format "HH:MM"
    hour = (time[0] + time[1]).to_i
    minute = (time[3] + time[4]).to_i

    return hour * 60 + minute # minutes = 60*hours + minutes
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

      if arrival_time < DateTime.now - (3.0/24.0)
          flash[:n1]="You must plan your trip at least two hours in advance"
      end

      if arrival_time > depart_time
          flash[:n2]=" You must arrive at the airport before you can depart"
      end
      
      if (plan_trip_params[:distance].to_i)<10
          flash[:n3]="Distance must be over 10 miles"
      end 
      
      if (plan_trip_params[:distance].to_i)>76
          flash[:n4]="Distance can not be over 75 miles"
      end 
  end
 
  def plan_trip_params
    params.require(:city).permit(:state, :distance, :airplane, :filter)
  end
  
end
