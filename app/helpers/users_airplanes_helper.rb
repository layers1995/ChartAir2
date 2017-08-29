module UsersAirplanesHelper
    
    #method to get airplane data, returns airplane_user prioritizes non-"destroyed" object
    def getAirplane(tailnumber, seenByUser)
        
        if seenByUser
            return AirplaneUser.find_by(:tailnumber => tailnumber, :user => current_user, :destroyed => seenByUser)
        else
            if AirplaneUser.find_by(:tailnumber => tailnumber, :user => current_user, :destroyed => seenByUser)!= nil
                return AirplaneUser.find_by(:tailnumber => tailnumber, :user => current_user, :destroyed => seenByUser)
            else
                return AirplaneUser.find_by(:tailnumber => tailnumber, :user => current_user, :destroyed => seenByUser)
            end
        end
        
    end
    
end
