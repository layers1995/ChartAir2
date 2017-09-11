class AirplaneUser < ApplicationRecord
    
    attr_accessor :manufacturer, :model
    
    validates :tailnumber, presence: true
    validate :tailnumber_unquie_user_can_see
    
    
    def tailnumber_unquie_user_can_see
        if AirplaneUser.find_by(:tailnumber => self.tailnumber, :user_can_see => true)!=nil
             errors.add(:tailnumber, " has already been taken")
        end
    end
    
end
