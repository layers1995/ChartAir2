class PlanTripController < ApplicationController
  
  def trip_details
      
    if not logged_in?
      redirect_to login_path and return
    end
    
    @tailnumber=params[:tailnumber]
    
    gon.cities= City.all
    gon.curAirplanes=current_airplanes
    gon.selectedPlane=@tailnumber
    
    if current_airplanes.length==0
        redirect_to profile_path
    end
    
    @plan_trip=""
    
  end

  def results
      
    if (params[:distance].to_i)<10
      redirect_to plantrip_path
    end
  	
  	@tailnumber=params[:airplane];
  	@curfilter= params[:filter]
  
  	#get the current city
  	curCity= City.find_by(:name => params[:city])
  	#get a refrence to the airplane being used
  	curAirplane= Airplane.find_by(:id => AirplaneUser.find_by(:tailnumber => @tailnumber).airplane_id)
  	
  	#Find all the airports within the area
  	airports=Airport.all
  	airportList=Array.new
  	
  	airports.each do |airport|

  	if airport.withinRadius(curCity.latitude, curCity.longitude, params[:distance].to_f)<params[:distance].to_f
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
  	  feeRecord=getFees(curAirplane, fbo)
      puts feeRecord.nil?
  	  
  	  if feeRecord!=nil
<<<<<<< HEAD
          feeRecord.each do |fee|
            #name of the fee and the price
            feeTotal+=fee.price
            feeDict[fbo.name][FeeType.find_by(:id => fee.fee_type_id).fee_type_description]=fee.price
          end
=======
        feeRecord.each do |fee|
          #name of the fee and the price
          feeTotal+=fee.price
          feeDict[fbo.name][FeeType.find_by(:id => fee.fee_type_id).fee_type_description]=fee.price
        end
>>>>>>> 0079090fd93ad787533cc8d96bd1631abc86e069
      end
  	  
  	  #add all other relivant information to dictonary like distance and airport
  	  fboAirport=Airport.find_by(:id => fbo.airport_id)
  	  feeDict[fbo.name]["total"]= feeTotal
  	  feeDict[fbo.name]["airport"]= fboAirport.name
  	  feeDict[fbo.name]["distance"]= fboAirport.withinRadius(curCity.latitude,curCity.longitude,params[:distance].to_f).to_i.to_s + " (mi)";
  	  
  	end

    return
  	
  	#send values to js
  	gon.dict= feeDict
  	
  end
  
  private 

  def getFees(airplane, fbo)
     
<<<<<<< HEAD
	    # get the classification from the fbo
	    if fbo.classification_id!=nil
	        
		    classification = Classification.find(fbo.classification_id)
		    
    		# get the category based on the classification and the airplane
    		case classification.classification_description
    		when "no fee"
    			category = Category.find_by( :category_description => "no fee")
    		when "flat rate"
    			category = Category.find_by( :category_description => "flat rate")
    		when "engine type"
    			category = Category.find_by( :category_description => airplane.engine_class)
    		when "make and model"
    			category = Category.find_by( :category_description => airplane.model)
    		when "weight range"
    			# I really doubt this will actually work, but that's the idea
    			#category = Category.find_by( :minimum => airplane.weight, :maximum > airplane.weight)
    		when "weight"
    			# I think this is where I'm going to need to redesign the schema. Maybe just add a column to category saying how much per x the fee is charged. So if it's $5 every 1000 pounds, that new column would be 1000
    		else
    			puts "That wasn't supposed to happen"
    		end
    
    			# return all fees where the category and fbo match what we're looking for. Should be up to 6 fees based on the different fee types
    		if !category.nil?
    			retFees = Fee.where( :category => category, :fbo => fbo )
    			if !retFees.nil?
    				return retFees
    			end
    		end
    		
	    end
 end
=======
    # get the classification from the fbo
    if fbo.classification_id != nil
        
      classification = Classification.find(fbo.classification_id)
      
  		# get the category based on the classification and the airplane
  		case classification.classification_description
  		when "no fee"
  			category = Category.find_by( :category_description => "no fee")
  		when "flat rate"
  			category = Category.find_by( :category_description => "flat rate")
  		when "engine type"
  			category = Category.find_by( :category_description => airplane.engine_class)
  		when "make and model"
  			category = Category.find_by( :category_description => airplane.model)
  		when "weight range"
  			# I really doubt this will actually work, but that's the idea
  			#category = Category.find_by( :minimum => airplane.weight, :maximum > airplane.weight)
  		when "weight"
  			# I think this is where I'm going to need to redesign the schema. Maybe just add a column to category saying how much per x the fee is charged. So if it's $5 every 1000 pounds, that new column would be 1000
  		else
  			puts "That wasn't supposed to happen"
  		end

  			# return all fees where the category and fbo match what we're looking for. Should be up to 6 fees based on the different fee types
  		if !category.nil?
  			retFees = Fee.where( :category => category, :fbo => fbo )
  			if !retFees.nil?
  				return retFees
  			end
  		end
    end
  end
>>>>>>> 0079090fd93ad787533cc8d96bd1631abc86e069
 
  #takes an active record of airports and returns an array
  def getAirportIds(airports)
     
    ids= Array.new(airports.length)
     
    airports.each do |airport|
      ids[i]=airport.id
    end
     
    return ids
     
  end
 
  def plan_trip_params
    params.require(:city).permit(:state, :distance, :airplane, :filter)
  end
  
end
