class FboPagesController < ApplicationController
  
  #shows all the fees, services and contact information for the fbo
  def fbo_profile
    
  end
  
  def fbo_confirm_prices
    #protect against doubles one which has no info
    fbos=Fbo.where(:name => params[:fbo], :airport_id => params[:airport_id].to_i)
    numFees=-1
    
    fbos.each do |fbo|
      if numFees<Fee.where(:fbo_id => fbo.id).length
        numFees=Fee.where(:fbo_id => fbo.id).length
        @fbo=fbo
      end
    end
    
    #get the values for the different categories here
    @feesLanding=Fee.where(:fbo_id => @fbo.id, :fee_type_id => FeeType.find_by(:fee_type_description => "landing").id)
    @feesRamp=Fee.where(:fbo_id => @fbo.id, :fee_type_id => FeeType.find_by(:fee_type_description => "ramp").id)
    @feesTieDown=Fee.where(:fbo_id => @fbo.id, :fee_type_id => FeeType.find_by(:fee_type_description => "tie down").id)
    @feesCallOut=Fee.where(:fbo_id => @fbo.id, :fee_type_id => FeeType.find_by(:fee_type_description => "call out").id)
    @feesOther =Fee.where(:fbo_id => @fbo.id, :fee_type_id => FeeType.find_by(:fee_type_description => "facility").id)
  end
  
  def fbo_search
    @search=""
  end
  
  def fbo_search_results
    
    curAirport= Airport.find_by(:airport_code => params[:airport_code].downcase)
    
    if curAirport!=nil
      
      if params[:wants_multiple]=="1"
        #find all fbos at these airports
        airports=Airport.all
    	  airportList=Array.new
    	
        airports.each do |airport|
  
      	if airport.withinRadius(curAirport.latitude, curAirport.longitude, 50.to_f)<50.to_f
      	    airportList.push(airport.id)
      	end
    
      	end
      	#find all the Fbos at these airports
      	@fbos= Fbo.where(:airport_id => airportList)
      	
      else
        
        curFbos=Fbo.where(:airport_id => curAirport.id)
        if curFbos!=nil
          if curFbos.length>1
            #if airport has one fbo bring to profile
            @fbos=curFbos
          else
            #more than one fbo send to results
            redirect_to fbo_confirm_path(:fbo => curFbos.first.name, :airport_id => curFbos.first.airport_id)
          end
        else
          #flash errors and refresh the page
          flash[:notice]="No results"
          @search=""
          render 'fbo_search' and return
        end
        
      end
      
    else
      #flash warnings and refresh page
      flash[:notice]="Airport Code not Found"
      @search=""
      render 'fbo_search' and return
    end
    
  end
  
  #holds the current fbo
  def fbo_update_options
    @fbo=Fbo.friendly.find(params[:fbo_id])
  end
  
  #form where fbo can input all of their data
  def fbo_form
    
  end
  
  def fbo_update_email
    @email=""
  end
  
  def fbo_update_form
    @fees=[]
  end
  
  def confirm_fees
    #change all of their fees to is_estimate=false
    curFbo=Fbo.where(:name => params[:fbo])
    fees= Fee.where(:fbo_id => curFbo.id)
    
    fees.each do |fee|
      fee.is_estimate=false
    end
    
    redirect_to 'congrats'
    
  end
  
end
