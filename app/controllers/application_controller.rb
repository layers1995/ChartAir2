class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  include SessionsHelper
  
  def test_data_base
      
      testResults= ""
      
      #create airplanes
      #for i in 0..100
      #  Airplane.create(model: "model "+i.to_s, engine_class: "engine "+i.to_s, weight: i, wingspan: i, length:i).save
      #end
      
      #for i in 0..100
      #  Airport.create(airport_code: "code " +i.to_s, name: "name " +i.to_s,latitude: i, longitude: i, state: "state" + i.to_s, index_airports_on_cities_id: i).save
      #end
      
      #for i in 0..100
        
      #end
      
      #airports=Airport.all
      
      #for airport in airports
       #   testResults+= airport.airport_code + " "
      #end
      
      render html: testResults
      
  end
  
  
end
