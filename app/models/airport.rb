class Airport < ApplicationRecord
	has_many :fbos
	belongs_to :city, optional: true
	
	
	#check if the airport is within the radius of the 
    def withinRadius(latitude,longitiude,radius)
      
          rad = 3963.1676
          lat1 = to_rad(latitude.to_f)
          lat2 = to_rad(self.latitude.to_f)
          lon1 = to_rad(longitiude.to_f)
          lon2 = to_rad(self.longitude.to_f)
          dLat = lat2-lat1   
          dLon = lon2-lon1
        
          a = Math::sin(dLat/2) * Math::sin(dLat/2) +
               Math::cos(lat1) * Math::cos(lat2) * 
               Math::sin(dLon/2) * Math::sin(dLon/2);
               
          c = 2 * Math::atan2(Math::sqrt(a), Math::sqrt(1-a));
          
          distance = rad * c
          
          #logger.debug "distance IS"
          #logger.debug distance
          #logger.debug "radius IS"
          #logger.debug radius
          
          return distance
    end

    def to_rad (angle)
      angle=angle * (Math::PI / 180)
      return angle
    end
    
end
